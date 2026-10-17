-- ServixPro initial schema: profiles, services, bookings, image storage.
-- Apply with `supabase db push`, or paste into the Supabase SQL editor.

-- ---------------------------------------------------------------------------
-- Profiles: one row per auth user, created automatically on sign-up.
-- ---------------------------------------------------------------------------
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null,
  email text not null,
  phone text not null default '',
  role text not null check (role in ('Customer', 'Provider')),
  profile_image text,
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, email, phone, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    new.email,
    coalesce(new.raw_user_meta_data ->> 'phone', ''),
    case when new.raw_user_meta_data ->> 'role' = 'Provider' then 'Provider' else 'Customer' end
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

alter table public.profiles enable row level security;

create policy "Profiles are visible to signed-in users"
  on public.profiles for select to authenticated
  using (true);

create policy "Users can update their own profile"
  on public.profiles for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- Users may edit their name, phone and avatar, but not their role or email.
revoke update on public.profiles from authenticated, anon;
grant update (full_name, phone, profile_image) on public.profiles to authenticated;

-- ---------------------------------------------------------------------------
-- Services: listed by providers, readable by everyone signed in.
-- ---------------------------------------------------------------------------
create table public.services (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null,
  category text not null,
  provider_id uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  price numeric(10, 2) not null check (price >= 0),
  image_url text,
  rating real not null default 0,
  availability boolean not null default true,
  created_at timestamptz not null default now()
);

create index services_provider_id_idx on public.services (provider_id);

create or replace function public.is_provider()
returns boolean
language sql
stable
security definer set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and role = 'Provider'
  );
$$;

alter table public.services enable row level security;

create policy "Services are visible to signed-in users"
  on public.services for select to authenticated
  using (true);

create policy "Providers can create their own services"
  on public.services for insert to authenticated
  with check (provider_id = (select auth.uid()) and public.is_provider());

create policy "Providers can update their own services"
  on public.services for update to authenticated
  using (provider_id = (select auth.uid()))
  with check (provider_id = (select auth.uid()));

create policy "Providers can delete their own services"
  on public.services for delete to authenticated
  using (provider_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Bookings: created by customers, accepted/rejected by the service's provider.
-- ---------------------------------------------------------------------------
create table public.bookings (
  id uuid primary key default gen_random_uuid(),
  service_id uuid not null references public.services (id) on delete cascade,
  customer_id uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  booking_date date not null,
  booking_status text not null default 'Pending'
    check (booking_status in ('Pending', 'Accepted', 'Rejected', 'Cancelled', 'Completed')),
  notes text,
  created_at timestamptz not null default now()
);

create index bookings_service_id_idx on public.bookings (service_id);
create index bookings_customer_id_idx on public.bookings (customer_id);

create or replace function public.owns_service(p_service_id uuid)
returns boolean
language sql
stable
security definer set search_path = ''
as $$
  select exists (
    select 1 from public.services
    where id = p_service_id and provider_id = (select auth.uid())
  );
$$;

alter table public.bookings enable row level security;

create policy "Customers and providers can see their bookings"
  on public.bookings for select to authenticated
  using (customer_id = (select auth.uid()) or public.owns_service(service_id));

create policy "Customers can request bookings"
  on public.bookings for insert to authenticated
  with check (customer_id = (select auth.uid()) and booking_status = 'Pending');

create policy "Customers and providers can update their bookings"
  on public.bookings for update to authenticated
  using (customer_id = (select auth.uid()) or public.owns_service(service_id));

-- Only the status can change after a booking is made.
revoke update on public.bookings from authenticated, anon;
grant update (booking_status) on public.bookings to authenticated;

-- Enforce who may move a booking to which status.
create or replace function public.check_booking_status_change()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  if new.booking_status = old.booking_status then
    return new;
  end if;

  if public.owns_service(old.service_id) then
    if (old.booking_status = 'Pending' and new.booking_status in ('Accepted', 'Rejected'))
       or (old.booking_status = 'Accepted' and new.booking_status = 'Completed') then
      return new;
    end if;
  end if;

  if old.customer_id = (select auth.uid()) then
    if old.booking_status in ('Pending', 'Accepted') and new.booking_status = 'Cancelled' then
      return new;
    end if;
  end if;

  raise exception 'Cannot change booking from % to %', old.booking_status, new.booking_status
    using errcode = '42501';
end;
$$;

create trigger check_booking_status_change
  before update on public.bookings
  for each row execute function public.check_booking_status_change();

-- ---------------------------------------------------------------------------
-- Storage: public "images" bucket; each user writes only under "<user id>/".
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('images', 'images', true)
on conflict (id) do nothing;

create policy "Users can upload images to their own folder"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'images' and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy "Users can update images in their own folder"
  on storage.objects for update to authenticated
  using (bucket_id = 'images' and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy "Users can delete images in their own folder"
  on storage.objects for delete to authenticated
  using (bucket_id = 'images' and (storage.foldername(name))[1] = (select auth.uid())::text);

# ServixPro

ServixPro is a cross-platform Service Marketplace application where customers can discover and book service providers for home and professional services such as electricians, plumbers, cleaners, tutors, technicians, beauticians, mechanics, and other skilled professionals.

## Features

- **User Authentication**: Secure sign-up and login with email/password and social logins.
- **User Dashboard**: Personalized dashboard for customers and providers.
- **Service Marketplace**: Browse and search for services with filters and categories.
- **Service Booking**: Customers can book services with date and time selection.
- **Service Management**: Providers can create, update, and delete services.
- **Notifications**: Real-time notifications for new bookings and updates.

## Backend

ServixPro uses [Supabase](https://supabase.com) for authentication, the database (profiles, services, bookings) and image storage. The schema, row-level security policies and storage bucket are defined in [`supabase/migrations`](supabase/migrations).

### Setup

1. Create a Supabase project.
2. Apply the schema, either with the [Supabase CLI](https://supabase.com/docs/guides/cli):
   ```sh
   supabase link --project-ref <your-project-ref>
   supabase db push
   ```
   or by pasting `supabase/migrations/20261017000000_init.sql` into the SQL editor in the dashboard.
3. Copy `supabase.env.example.json` to `supabase.env.json` (git-ignored) and fill in the project URL and publishable key from **Project Settings → API Keys**.
4. Run the app:
   ```sh
   flutter run --dart-define-from-file=supabase.env.json
   ```
   Use the same flag for `flutter build`.

By default Supabase asks new users to confirm their email address before they can log in; the app handles this. To skip it during development, turn off **Confirm email** under **Authentication → Sign In / Providers**.

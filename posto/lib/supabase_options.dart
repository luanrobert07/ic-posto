class SupabaseOptions {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://gsyueuljyndlkvishpyp.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdzeXVldWxqeW5kbGt2aXNocHlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjExNzY1NTcsImV4cCI6MjA3Njc1MjU1N30.ERObPqilt_Jtjco_P_9KkZvdNkAAXtmT3s8BYqJw-Xc',
  );
}

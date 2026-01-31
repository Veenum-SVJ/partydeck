-- 1. Create the 'rooms' table
CREATE TABLE public.rooms (
    code text NOT NULL PRIMARY KEY,
    state jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
-- 2. Enable Realtime for this table
-- This allows the app to listen for game updates.
ALTER PUBLICATION supabase_realtime
ADD TABLE public.rooms;
-- 3. Disable Row Level Security (RLS) for the Prototype
-- WARNING: In a production app with Auth, you should enable RLS and strictly define policies.
-- For this prototype (where we use anonymous UUIDs without Auth), we will allow public access.
ALTER TABLE public.rooms DISABLE ROW LEVEL SECURITY;
-- ALTERNATIVE: If RLS is forced on, use this "Allow All" policy:
-- ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Allow Public Access" ON public.rooms FOR ALL USING (true) WITH CHECK (true);
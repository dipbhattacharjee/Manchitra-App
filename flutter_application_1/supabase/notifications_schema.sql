-- MANCHITRA — Notifications & Preferences Schema (Supabase SQL)

-- 1. Main Notifications Table
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category TEXT NOT NULL CHECK (category IN ('crowd_alert', 'festival_update', 'nearby_offer', 'system')),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  related_pandal_id UUID REFERENCES public.pandals(id) ON DELETE SET NULL,
  deep_link TEXT, -- e.g. 'manchitra://pandal/<id>' or 'manchitra://route/<id>'
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. User Notifications Table (Per-user delivery & read status)
CREATE TABLE IF NOT EXISTS public.user_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  notification_id UUID REFERENCES public.notifications(id) ON DELETE CASCADE NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT false,
  delivered_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, notification_id)
);

-- 3. User Notification Preferences Table
CREATE TABLE IF NOT EXISTS public.user_notification_preferences (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  crowd_alerts_enabled BOOLEAN NOT NULL DEFAULT true,
  festival_updates_enabled BOOLEAN NOT NULL DEFAULT true,
  nearby_offers_enabled BOOLEAN NOT NULL DEFAULT true,
  system_enabled BOOLEAN NOT NULL DEFAULT true,
  quiet_hours_enabled BOOLEAN NOT NULL DEFAULT false,
  quiet_hours_start TIME DEFAULT '23:00',
  quiet_hours_end TIME DEFAULT '07:00',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_notification_preferences ENABLE ROW LEVEL SECURITY;

-- Policies for Notifications
CREATE POLICY "Allow public read access to notifications" ON public.notifications
  FOR SELECT USING (true);

-- Policies for User Notifications
CREATE POLICY "Users can read own user_notifications" ON public.user_notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own user_notifications" ON public.user_notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- Policies for User Notification Preferences
CREATE POLICY "Users can manage own preferences" ON public.user_notification_preferences
  FOR ALL USING (auth.uid() = user_id);

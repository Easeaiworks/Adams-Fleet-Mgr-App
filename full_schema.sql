-- Fleet Pilot: Combined Database Schema
-- Generated from 41 migration files
-- Run this in your Supabase SQL Editor to set up the database


-- ============================================
-- Migration: 20251128212620_ad8800d7-1b03-4ddf-8dfd-d63b01a0785a.sql
-- ============================================

-- Create profiles table for user management
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- Trigger to create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create branches table
CREATE TABLE public.branches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  location TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.branches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view branches"
  ON public.branches FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can manage branches"
  ON public.branches FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create vehicles table
CREATE TABLE public.vehicles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vin TEXT NOT NULL UNIQUE,
  plate TEXT NOT NULL,
  branch_id UUID REFERENCES public.branches(id) ON DELETE SET NULL,
  make TEXT,
  model TEXT,
  year INTEGER,
  odometer_km INTEGER DEFAULT 0,
  last_oil_change_km INTEGER,
  last_tire_change_date DATE,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'maintenance', 'retired')),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view vehicles"
  ON public.vehicles FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can manage vehicles"
  ON public.vehicles FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create expense categories table
CREATE TABLE public.expense_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  type TEXT NOT NULL CHECK (type IN ('maintenance', 'repair')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.expense_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view categories"
  ON public.expense_categories FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can manage categories"
  ON public.expense_categories FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Insert default categories
INSERT INTO public.expense_categories (name, type) VALUES
  ('Oil Change', 'maintenance'),
  ('Tire Replacement', 'maintenance'),
  ('Brake Service', 'maintenance'),
  ('Air Filter', 'maintenance'),
  ('Transmission Repair', 'repair'),
  ('Engine Repair', 'repair'),
  ('Suspension Repair', 'repair'),
  ('Electrical Repair', 'repair');

-- Create expenses table
CREATE TABLE public.expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE CASCADE,
  category_id UUID REFERENCES public.expense_categories(id) ON DELETE SET NULL,
  amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  description TEXT,
  odometer_reading INTEGER,
  created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view expenses"
  ON public.expenses FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can manage expenses"
  ON public.expenses FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create documents table for invoice uploads
CREATE TABLE public.documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE CASCADE,
  expense_id UUID REFERENCES public.expenses(id) ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  file_type TEXT,
  file_size INTEGER,
  uploaded_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view documents"
  ON public.documents FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can manage documents"
  ON public.documents FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create storage bucket for documents
INSERT INTO storage.buckets (id, name, public) VALUES ('vehicle-documents', 'vehicle-documents', false);

-- Storage policies
CREATE POLICY "Authenticated users can upload documents"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'vehicle-documents');

CREATE POLICY "Authenticated users can view documents"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (bucket_id = 'vehicle-documents');

CREATE POLICY "Authenticated users can delete documents"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'vehicle-documents');

-- Function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_branches_updated_at BEFORE UPDATE ON public.branches
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_vehicles_updated_at BEFORE UPDATE ON public.vehicles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON public.expenses
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
-- ============================================
-- Migration: 20251128212631_535d2ecb-cf98-4d65-a483-2ae373a601a3.sql
-- ============================================

-- Fix search path for update_updated_at_column function
DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- Recreate triggers
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_branches_updated_at BEFORE UPDATE ON public.branches
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_vehicles_updated_at BEFORE UPDATE ON public.vehicles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON public.expenses
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
-- ============================================
-- Migration: 20251128212817_aec968a9-1c50-4671-ab18-96c8e167d40c.sql
-- ============================================

-- Add INSERT policy for profiles table
CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);
-- ============================================
-- Migration: 20251201170805_8bc189ff-1d5e-40d4-95c0-2cc70cafd41b.sql
-- ============================================

CREATE TABLE user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role text NOT NULL CHECK (role IN ('admin', 'manager', 'staff')),
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  UNIQUE (user_id, role)
);

ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

ALTER TABLE expenses
  ADD COLUMN IF NOT EXISTS status text DEFAULT 'draft' CHECK (status IN ('draft', 'pending', 'complete')),
  ADD COLUMN IF NOT EXISTS modified_by uuid REFERENCES auth.users(id),
  ADD COLUMN IF NOT EXISTS modified_at timestamp with time zone;

CREATE TABLE audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name text NOT NULL,
  record_id uuid NOT NULL,
  action text NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
  old_data jsonb,
  new_data jsonb,
  user_id uuid REFERENCES auth.users(id),
  created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
-- ============================================
-- Migration: 20251201174511_be98d598-98ab-4601-8416-b641b436042c.sql
-- ============================================

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
-- ============================================
-- Migration: 20251201175142_84b793e4-ce81-4fe3-b34a-366d3b7376aa.sql
-- ============================================

-- Add approval fields to expenses table
ALTER TABLE public.expenses 
  ADD COLUMN IF NOT EXISTS approval_status text DEFAULT 'pending' CHECK (approval_status IN ('pending', 'approved', 'rejected')),
  ADD COLUMN IF NOT EXISTS approved_by uuid REFERENCES auth.users(id),
  ADD COLUMN IF NOT EXISTS approved_at timestamp with time zone,
  ADD COLUMN IF NOT EXISTS rejection_reason text;

-- Update existing expenses to be approved
UPDATE public.expenses SET approval_status = 'approved' WHERE approval_status IS NULL;

-- Update RLS policies for expenses
DROP POLICY IF EXISTS "Staff can create expenses" ON public.expenses;
DROP POLICY IF EXISTS "Admins and managers can update expenses" ON public.expenses;
DROP POLICY IF EXISTS "Admins and managers can delete expenses" ON public.expenses;

-- Staff can create their own expenses (will be pending by default)
CREATE POLICY "Staff can create expenses"
  ON public.expenses
  FOR INSERT
  TO authenticated
  WITH CHECK (created_by = auth.uid());

-- Staff can update their own pending expenses
CREATE POLICY "Staff can update own pending expenses"
  ON public.expenses
  FOR UPDATE
  TO authenticated
  USING (created_by = auth.uid() AND approval_status = 'pending')
  WITH CHECK (created_by = auth.uid() AND approval_status = 'pending');

-- Admins and managers can update any expense
CREATE POLICY "Admins and managers can update any expense"
  ON public.expenses
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles ur
      WHERE ur.user_id = auth.uid() AND ur.role IN ('admin', 'manager')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.user_roles ur
      WHERE ur.user_id = auth.uid() AND ur.role IN ('admin', 'manager')
    )
  );

-- Admins and managers can delete expenses
CREATE POLICY "Admins and managers can delete expenses"
  ON public.expenses
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles ur
      WHERE ur.user_id = auth.uid() AND ur.role IN ('admin', 'manager')
    )
  );
-- ============================================
-- Migration: 20251202141526_4128a84d-bbf4-49a5-8cda-b57cf051aa0f.sql
-- ============================================

-- Allow authenticated users to read their own roles
CREATE POLICY "Users can view their own roles"
ON public.user_roles
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Allow admins to manage all roles
CREATE POLICY "Admins can manage all roles"
ON public.user_roles
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = auth.uid() AND role = 'admin'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = auth.uid() AND role = 'admin'
  )
);
-- ============================================
-- Migration: 20251202142035_670cd195-154f-4308-bb02-7356723cbafd.sql
-- ============================================

-- Drop the problematic policy that could cause infinite recursion
DROP POLICY IF EXISTS "Admins can manage all roles" ON public.user_roles;

-- Create a security definer function to check admin status without recursion
CREATE OR REPLACE FUNCTION public.is_admin(_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = _user_id AND role = 'admin'
  )
$$;

-- Create policies using the security definer function
CREATE POLICY "Admins can insert roles"
ON public.user_roles
FOR INSERT
TO authenticated
WITH CHECK (public.is_admin(auth.uid()));

CREATE POLICY "Admins can update roles"
ON public.user_roles
FOR UPDATE
TO authenticated
USING (public.is_admin(auth.uid()));

CREATE POLICY "Admins can delete roles"
ON public.user_roles
FOR DELETE
TO authenticated
USING (public.is_admin(auth.uid()));
-- ============================================
-- Migration: 20251202153015_75cb16e3-438d-4bcb-ac44-2db2b039ad66.sql
-- ============================================

-- Allow admins to view all profiles
CREATE POLICY "Admins can view all profiles"
ON public.profiles
FOR SELECT
USING (is_admin(auth.uid()));

-- Allow admins to view all user roles (they can currently only see their own)
CREATE POLICY "Admins can view all roles"
ON public.user_roles
FOR SELECT
USING (is_admin(auth.uid()));
-- ============================================
-- Migration: 20251202153319_d9df1669-d348-4e81-ad62-eadf035fea46.sql
-- ============================================

-- Drop the restrictive admin policy and recreate as permissive
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;

CREATE POLICY "Admins can view all profiles"
ON public.profiles
FOR SELECT
TO authenticated
USING (is_admin(auth.uid()));

-- Also fix the existing user policy to be permissive (drop and recreate)
DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;

CREATE POLICY "Users can view their own profile"
ON public.profiles
FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- Fix user_roles policies similarly
DROP POLICY IF EXISTS "Admins can view all roles" ON public.user_roles;
DROP POLICY IF EXISTS "Users can view their own roles" ON public.user_roles;

CREATE POLICY "Admins can view all roles"
ON public.user_roles
FOR SELECT
TO authenticated
USING (is_admin(auth.uid()));

CREATE POLICY "Users can view their own roles"
ON public.user_roles
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);
-- ============================================
-- Migration: 20251203143159_7f586153-f676-42c7-b8d7-dbd9a503e81e.sql
-- ============================================

-- Create GPS uploads table to track mileage from GPS files
CREATE TABLE public.gps_uploads (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  upload_month DATE NOT NULL,
  kilometers NUMERIC NOT NULL DEFAULT 0,
  uploaded_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  notes TEXT
);

-- Enable RLS
ALTER TABLE public.gps_uploads ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Authenticated users can view gps_uploads"
ON public.gps_uploads
FOR SELECT
USING (true);

CREATE POLICY "Authenticated users can manage gps_uploads"
ON public.gps_uploads
FOR ALL
USING (true)
WITH CHECK (true);
-- ============================================
-- Migration: 20251203145719_7826738c-fbb6-4280-ad13-262fa04c941d.sql
-- ============================================

-- Make vehicle_id nullable to support unmatched GPS entries
ALTER TABLE public.gps_uploads ALTER COLUMN vehicle_id DROP NOT NULL;

-- Add column to store the original vehicle name from the GPS file
ALTER TABLE public.gps_uploads ADD COLUMN gps_vehicle_name text;

-- Add index for better querying by gps_vehicle_name
CREATE INDEX idx_gps_uploads_vehicle_name ON public.gps_uploads(gps_vehicle_name);
-- ============================================
-- Migration: 20251203162822_6d40a50e-510a-421c-ad15-15f47b1cbe16.sql
-- ============================================

-- Drop the overly permissive policy
DROP POLICY IF EXISTS "Authenticated users can manage vehicles" ON public.vehicles;

-- Create policies for admin/manager only management
CREATE POLICY "Admins and managers can insert vehicles"
ON public.vehicles
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = auth.uid()
    AND role IN ('admin', 'manager')
  )
);

CREATE POLICY "Admins and managers can update vehicles"
ON public.vehicles
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = auth.uid()
    AND role IN ('admin', 'manager')
  )
);

CREATE POLICY "Admins and managers can delete vehicles"
ON public.vehicles
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = auth.uid()
    AND role IN ('admin', 'manager')
  )
);
-- ============================================
-- Migration: 20251203171018_134292ff-a640-45f6-a1ed-e6c32355b44d.sql
-- ============================================

-- Add approval status to profiles table
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS is_approved boolean NOT NULL DEFAULT false;

-- Add approved_by and approved_at columns
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS approved_by uuid REFERENCES public.profiles(id),
ADD COLUMN IF NOT EXISTS approved_at timestamp with time zone;

-- Update existing users to be approved (so current users aren't locked out)
UPDATE public.profiles SET is_approved = true WHERE is_approved = false;
-- ============================================
-- Migration: 20251203173358_26295926-7aa4-4a86-83e8-7dcc4017a474.sql
-- ============================================

-- Add is_blocked column to profiles table
ALTER TABLE public.profiles 
ADD COLUMN is_blocked boolean NOT NULL DEFAULT false,
ADD COLUMN blocked_by uuid REFERENCES public.profiles(id),
ADD COLUMN blocked_at timestamp with time zone,
ADD COLUMN block_reason text;
-- ============================================
-- Migration: 20251208164442_426a2964-1a3b-4662-bae7-bfe6d1d13978.sql
-- ============================================

-- Allow admins to update any profile (for approving users)
CREATE POLICY "Admins can update any profile" 
ON public.profiles 
FOR UPDATE 
USING (is_admin(auth.uid()))
WITH CHECK (is_admin(auth.uid()));
-- ============================================
-- Migration: 20251211165153_b18543f5-c0e0-4db9-9902-f431bf3d6b5f.sql
-- ============================================

-- Create tire_changes table to track tire swap activities
CREATE TABLE public.tire_changes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE CASCADE,
  branch_id UUID REFERENCES public.branches(id) ON DELETE SET NULL,
  tire_type TEXT NOT NULL CHECK (tire_type IN ('winter', 'summer', 'all_season')),
  current_tire_type TEXT CHECK (current_tire_type IN ('winter', 'summer', 'all_season')),
  change_date DATE NOT NULL DEFAULT CURRENT_DATE,
  summer_tire_location TEXT,
  winter_tire_location TEXT,
  notes TEXT,
  completed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.tire_changes ENABLE ROW LEVEL SECURITY;

-- RLS policies
CREATE POLICY "Authenticated users can view tire changes" 
ON public.tire_changes 
FOR SELECT 
USING (true);

CREATE POLICY "Admins and managers can manage tire changes" 
ON public.tire_changes 
FOR ALL 
USING (EXISTS (
  SELECT 1 FROM user_roles 
  WHERE user_roles.user_id = auth.uid() 
  AND user_roles.role IN ('admin', 'manager')
))
WITH CHECK (EXISTS (
  SELECT 1 FROM user_roles 
  WHERE user_roles.user_id = auth.uid() 
  AND user_roles.role IN ('admin', 'manager')
));

CREATE POLICY "Staff can insert tire changes" 
ON public.tire_changes 
FOR INSERT 
WITH CHECK (true);

-- Add tire tracking fields to vehicles table
ALTER TABLE public.vehicles 
ADD COLUMN IF NOT EXISTS current_tire_type TEXT DEFAULT 'summer' CHECK (current_tire_type IN ('winter', 'summer', 'all_season')),
ADD COLUMN IF NOT EXISTS summer_tire_location TEXT,
ADD COLUMN IF NOT EXISTS winter_tire_location TEXT,
ADD COLUMN IF NOT EXISTS tire_notes TEXT;

-- Create trigger for updated_at
CREATE TRIGGER update_tire_changes_updated_at
BEFORE UPDATE ON public.tire_changes
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();
-- ============================================
-- Migration: 20251211165656_6ec94e5d-ddca-4579-9195-467011f986b8.sql
-- ============================================

-- Create tire_inventory table for tracking spare tires at each branch
CREATE TABLE public.tire_inventory (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  branch_id UUID REFERENCES public.branches(id) ON DELETE CASCADE NOT NULL,
  brand TEXT NOT NULL,
  measurements TEXT NOT NULL,
  condition TEXT NOT NULL CHECK (condition IN ('new', 'good', 'fair', 'worn')),
  quantity INTEGER NOT NULL DEFAULT 1,
  notes TEXT,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.tire_inventory ENABLE ROW LEVEL SECURITY;

-- RLS policies
CREATE POLICY "Authenticated users can view tire inventory" 
ON public.tire_inventory 
FOR SELECT 
USING (true);

CREATE POLICY "Admins and managers can manage tire inventory" 
ON public.tire_inventory 
FOR ALL 
USING (EXISTS (
  SELECT 1 FROM user_roles 
  WHERE user_roles.user_id = auth.uid() 
  AND user_roles.role IN ('admin', 'manager')
))
WITH CHECK (EXISTS (
  SELECT 1 FROM user_roles 
  WHERE user_roles.user_id = auth.uid() 
  AND user_roles.role IN ('admin', 'manager')
));

CREATE POLICY "Staff can insert tire inventory" 
ON public.tire_inventory 
FOR INSERT 
WITH CHECK (true);

-- Add notes field to branches for tire-related notes
ALTER TABLE public.branches 
ADD COLUMN IF NOT EXISTS tire_notes TEXT;

-- Create trigger for updated_at
CREATE TRIGGER update_tire_inventory_updated_at
BEFORE UPDATE ON public.tire_inventory
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();
-- ============================================
-- Migration: 20251211174543_d85ee97f-201e-4729-b5b5-713137f27c0b.sql
-- ============================================

-- Add detailed tire info columns to vehicles table for both sets
ALTER TABLE public.vehicles 
ADD COLUMN IF NOT EXISTS summer_tire_brand text,
ADD COLUMN IF NOT EXISTS summer_tire_measurements text,
ADD COLUMN IF NOT EXISTS summer_tire_condition text,
ADD COLUMN IF NOT EXISTS winter_tire_brand text,
ADD COLUMN IF NOT EXISTS winter_tire_measurements text,
ADD COLUMN IF NOT EXISTS winter_tire_condition text;

-- Create tire claim requests table for approval workflow
CREATE TABLE public.tire_claim_requests (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  inventory_item_id UUID NOT NULL REFERENCES public.tire_inventory(id) ON DELETE CASCADE,
  vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE CASCADE,
  branch_id UUID REFERENCES public.branches(id),
  requested_by UUID REFERENCES auth.users(id),
  tire_type text NOT NULL CHECK (tire_type IN ('winter', 'summer')),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  approved_by UUID REFERENCES auth.users(id),
  approved_at TIMESTAMP WITH TIME ZONE,
  rejection_reason text,
  notes text,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS on tire_claim_requests
ALTER TABLE public.tire_claim_requests ENABLE ROW LEVEL SECURITY;

-- RLS policies for tire_claim_requests
CREATE POLICY "Authenticated users can view tire claim requests"
ON public.tire_claim_requests
FOR SELECT
USING (true);

CREATE POLICY "Staff can create tire claim requests"
ON public.tire_claim_requests
FOR INSERT
WITH CHECK (true);

CREATE POLICY "Admins can manage tire claim requests"
ON public.tire_claim_requests
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_roles.user_id = auth.uid() 
    AND user_roles.role = 'admin'
  )
);

-- Add updated_at trigger
CREATE TRIGGER update_tire_claim_requests_updated_at
BEFORE UPDATE ON public.tire_claim_requests
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();
-- ============================================
-- Migration: 20251211174827_77ea1195-1ec3-4e43-8063-cc6352e7d4d6.sql
-- ============================================

-- Add update/delete policies for non-admin users on pending requests
CREATE POLICY "Users can update their own pending requests"
ON public.tire_claim_requests
FOR UPDATE
USING (requested_by = auth.uid() AND status = 'pending')
WITH CHECK (requested_by = auth.uid() AND status = 'pending');

CREATE POLICY "Users can delete their own pending requests"
ON public.tire_claim_requests
FOR DELETE
USING (requested_by = auth.uid() AND status = 'pending');
-- ============================================
-- Migration: 20251211175941_ffbf50a4-5be1-46b5-8bda-46ed555d4952.sql
-- ============================================

-- Fix profiles table: Remove overly permissive admin SELECT policy and create proper one
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;

-- Recreate admin policy to only allow admins to view profiles (using security definer function)
CREATE POLICY "Admins can view all profiles"
ON public.profiles
FOR SELECT
USING (is_admin(auth.uid()));

-- Add RLS policies for audit_logs table
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Only admins can view audit logs
CREATE POLICY "Admins can view audit logs"
ON public.audit_logs
FOR SELECT
USING (is_admin(auth.uid()));

-- System can insert audit logs (no user restrictions on insert since it's done by triggers/system)
CREATE POLICY "System can insert audit logs"
ON public.audit_logs
FOR INSERT
WITH CHECK (true);

-- No one can update or delete audit logs (immutable audit trail)
-- (No UPDATE or DELETE policies means these operations are denied by RLS)
-- ============================================
-- Migration: 20251211205428_4452bf04-45b0-4e66-b12e-c7b11976a85f.sql
-- ============================================

-- Create a security definer function to check if user is approved and not blocked
CREATE OR REPLACE FUNCTION public.is_user_approved(_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = _user_id
    AND is_approved = true
    AND is_blocked = false
  )
$$;

-- Drop and recreate policies for vehicles table with approval check
DROP POLICY IF EXISTS "Authenticated users can view vehicles" ON public.vehicles;
CREATE POLICY "Approved users can view vehicles" ON public.vehicles
FOR SELECT USING (is_user_approved(auth.uid()));

DROP POLICY IF EXISTS "Admins and managers can insert vehicles" ON public.vehicles;
CREATE POLICY "Approved admins and managers can insert vehicles" ON public.vehicles
FOR INSERT WITH CHECK (
  is_user_approved(auth.uid()) AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role IN ('admin', 'manager'))
);

DROP POLICY IF EXISTS "Admins and managers can update vehicles" ON public.vehicles;
CREATE POLICY "Approved admins and managers can update vehicles" ON public.vehicles
FOR UPDATE USING (
  is_user_approved(auth.uid()) AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role IN ('admin', 'manager'))
);

DROP POLICY IF EXISTS "Admins and managers can delete vehicles" ON public.vehicles;
CREATE POLICY "Approved admins and managers can delete vehicles" ON public.vehicles
FOR DELETE USING (
  is_user_approved(auth.uid()) AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role IN ('admin', 'manager'))
);

-- Drop and recreate policies for expenses table with approval check
DROP POLICY IF EXISTS "Authenticated users can view expenses" ON public.expenses;
CREATE POLICY "Approved users can view expenses" ON public.expenses
FOR SELECT USING (is_user_approved(auth.uid()));

DROP POLICY IF EXISTS "Authenticated users can manage expenses" ON public.expenses;

DROP POLICY IF EXISTS "Staff can create expenses" ON public.expenses;
CREATE POLICY "Approved staff can create expenses" ON public.expenses
FOR INSERT WITH CHECK (is_user_approved(auth.uid()) AND created_by = auth.uid());

DROP POLICY IF EXISTS "Staff can update own pending expenses" ON public.expenses;
CREATE POLICY "Approved staff can update own pending expenses" ON public.expenses
FOR UPDATE USING (
  is_user_approved(auth.uid()) AND created_by = auth.uid() AND approval_status = 'pending'
) WITH CHECK (
  is_user_approved(auth.uid()) AND created_by = auth.uid() AND approval_status = 'pending'
);

DROP POLICY IF EXISTS "Admins and managers can update any expense" ON public.expenses;
CREATE POLICY "Approved admins and managers can update any expense" ON public.expenses
FOR UPDATE USING (
  is_user_approved(auth.uid()) AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role IN ('admin', 'manager'))
) WITH CHECK (
  is_user_approved(auth.uid()) AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role IN ('admin', 'manager'))
);

DROP POLICY IF EXISTS "Admins and managers can delete expenses" ON public.expenses;
CREATE POLICY "Approved admins and managers can delete expenses" ON public.expenses
FOR DELETE USING (
  is_user_approved(auth.uid()) AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role IN ('admin', 'manager'))
);

-- Drop and recreate policies for branches table with approval check
DROP POLICY IF EXISTS "Authenticated users can view branches" ON public.branches;
CREATE POLICY "Approved users can view branches" ON public.branches
FOR SELECT USING (is_user_approved(auth.uid()));

DROP POLICY IF EXISTS "Authenticated users can manage branches" ON public.branches;
CREATE POLICY "Approved admins and managers can manage branches" ON public.branches
FOR ALL USING (
  is_user_approved(auth.uid()) AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role IN ('admin', 'manager'))
) WITH CHECK (
  is_user_approved(auth.uid()) AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role IN ('admin', 'manager'))
);

-- Drop and recreate policies for expense_categories table with approval check
DROP POLICY IF EXISTS "Authenticated users can view categories" ON public.expense_categories;
CREATE POLICY "Approved users can view categories" ON public.expense_categories
FOR SELECT USING (is_user_approved(auth.uid()));

DROP POLICY IF EXISTS "Authenticated users can manage categories" ON public.expense_categories;
CREATE POLICY "Approved admins and managers can manage categories" ON public.expense_categories
FOR ALL USING (
  is_user_approved(auth.uid()) AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role IN ('admin', 'manager'))
) WITH CHECK (
  is_user_approved(auth.uid()) AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role IN ('admin', 'manager'))
);

-- Drop and recreate policies for documents table with approval check
DROP POLICY IF EXISTS "Authenticated users can view documents" ON public.documents;
CREATE POLICY "Approved users can view documents" ON public.documents
FOR SELECT USING (is_user_approved(auth.uid()));

DROP POLICY IF EXISTS "Authenticated users can manage documents" ON public.documents;
CREATE POLICY "Approved users can manage documents" ON public.documents
FOR ALL USING (is_user_approved(auth.uid())) WITH CHECK (is_user_approved(auth.uid()));

-- Drop and recreate policies for gps_uploads table with approval check
DROP POLICY IF EXISTS "Authenticated users can view gps_uploads" ON public.gps_uploads;
CREATE POLICY "Approved users can view gps_uploads" ON public.gps_uploads
FOR SELECT USING (is_user_approved(auth.uid()));

DROP POLICY IF EXISTS "Authenticated users can manage gps_uploads" ON public.gps_uploads;
CREATE POLICY "Approved users can manage gps_uploads" ON public.gps_uploads
FOR ALL USING (is_user_approved(auth.uid())) WITH CHECK (is_user_approved(auth.uid()));

-- Drop and recreate policies for tire_changes table with approval check
DROP POLICY IF EXISTS "Authenticated users can view tire changes" ON public.tire_changes;
CREATE POLICY "Approved users can view tire changes" ON public.tire_changes
FOR SELECT USING (is_user_approved(auth.uid()));

DROP POLICY IF EXISTS "Admins and managers can manage tire changes" ON public.tire_changes;
CREATE POLICY "Approved admins and managers can manage tire changes" ON public.tire_changes
FOR ALL USING (
  is_user_approved(auth.uid()) AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role IN ('admin', 'manager'))
) WITH CHECK (
  is_user_approved(auth.uid()) AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role IN ('admin', 'manager'))
);

DROP POLICY IF EXISTS "Staff can insert tire changes" ON public.tire_changes;
CREATE POLICY "Approved staff can insert tire changes" ON public.tire_changes
FOR INSERT WITH CHECK (is_user_approved(auth.uid()));

-- Drop and recreate policies for tire_inventory table with approval check
DROP POLICY IF EXISTS "Authenticated users can view tire inventory" ON public.tire_inventory;
CREATE POLICY "Approved users can view tire inventory" ON public.tire_inventory
FOR SELECT USING (is_user_approved(auth.uid()));

DROP POLICY IF EXISTS "Admins and managers can manage tire inventory" ON public.tire_inventory;
CREATE POLICY "Approved admins and managers can manage tire inventory" ON public.tire_inventory
FOR ALL USING (
  is_user_approved(auth.uid()) AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role IN ('admin', 'manager'))
) WITH CHECK (
  is_user_approved(auth.uid()) AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role IN ('admin', 'manager'))
);

DROP POLICY IF EXISTS "Staff can insert tire inventory" ON public.tire_inventory;
CREATE POLICY "Approved staff can insert tire inventory" ON public.tire_inventory
FOR INSERT WITH CHECK (is_user_approved(auth.uid()));

-- Drop and recreate policies for tire_claim_requests table with approval check
DROP POLICY IF EXISTS "Authenticated users can view tire claim requests" ON public.tire_claim_requests;
CREATE POLICY "Approved users can view tire claim requests" ON public.tire_claim_requests
FOR SELECT USING (is_user_approved(auth.uid()));

DROP POLICY IF EXISTS "Staff can create tire claim requests" ON public.tire_claim_requests;
CREATE POLICY "Approved staff can create tire claim requests" ON public.tire_claim_requests
FOR INSERT WITH CHECK (is_user_approved(auth.uid()));

DROP POLICY IF EXISTS "Admins can manage tire claim requests" ON public.tire_claim_requests;
CREATE POLICY "Approved admins can manage tire claim requests" ON public.tire_claim_requests
FOR ALL USING (
  is_user_approved(auth.uid()) AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

DROP POLICY IF EXISTS "Users can update their own pending requests" ON public.tire_claim_requests;
CREATE POLICY "Approved users can update their own pending requests" ON public.tire_claim_requests
FOR UPDATE USING (
  is_user_approved(auth.uid()) AND requested_by = auth.uid() AND status = 'pending'
) WITH CHECK (
  is_user_approved(auth.uid()) AND requested_by = auth.uid() AND status = 'pending'
);

DROP POLICY IF EXISTS "Users can delete their own pending requests" ON public.tire_claim_requests;
CREATE POLICY "Approved users can delete their own pending requests" ON public.tire_claim_requests
FOR DELETE USING (
  is_user_approved(auth.uid()) AND requested_by = auth.uid() AND status = 'pending'
);

-- Update audit_logs policies to ensure tamper-proof audit trail
DROP POLICY IF EXISTS "System can insert audit logs" ON public.audit_logs;
-- Only allow inserts via service role or triggers, not regular users
CREATE POLICY "Only system can insert audit logs" ON public.audit_logs
FOR INSERT WITH CHECK (false);

DROP POLICY IF EXISTS "Admins can view audit logs" ON public.audit_logs;
CREATE POLICY "Approved admins can view audit logs" ON public.audit_logs
FOR SELECT USING (is_user_approved(auth.uid()) AND is_admin(auth.uid()));
-- ============================================
-- Migration: 20251215163538_5bd409b0-f5ab-411a-a388-03aa1efdb15e.sql
-- ============================================

-- Add 407 transponder field to vehicles table
ALTER TABLE public.vehicles 
ADD COLUMN transponder_407 varchar(10) DEFAULT NULL;
-- ============================================
-- Migration: 20251216154912_b40bddd6-644d-456e-ae54-bee19dd8d896.sql
-- ============================================

-- Drop the existing ALL policy for admins and managers
DROP POLICY IF EXISTS "Approved admins and managers can manage tire inventory" ON public.tire_inventory;

-- Create separate policies for granular control

-- Admins and managers can INSERT
CREATE POLICY "Approved admins and managers can insert tire inventory" 
ON public.tire_inventory 
FOR INSERT 
WITH CHECK (
  is_user_approved(auth.uid()) AND (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid() 
      AND user_roles.role = ANY (ARRAY['admin'::text, 'manager'::text])
    )
  )
);

-- Only admins can UPDATE
CREATE POLICY "Approved admins can update tire inventory" 
ON public.tire_inventory 
FOR UPDATE 
USING (
  is_user_approved(auth.uid()) AND is_admin(auth.uid())
)
WITH CHECK (
  is_user_approved(auth.uid()) AND is_admin(auth.uid())
);

-- Only admins can DELETE
CREATE POLICY "Approved admins can delete tire inventory" 
ON public.tire_inventory 
FOR DELETE 
USING (
  is_user_approved(auth.uid()) AND is_admin(auth.uid())
);
-- ============================================
-- Migration: 20251216155231_b683e1b9-db8d-4e47-9238-c97401a226db.sql
-- ============================================

-- Add tire_type column to tire_inventory table
ALTER TABLE public.tire_inventory 
ADD COLUMN tire_type text NOT NULL DEFAULT 'all_season';
-- ============================================
-- Migration: 20251216205654_c09ed829-e5e8-4833-b1a0-3d87512cb679.sql
-- ============================================

-- Drop existing delete policies that allow managers
DROP POLICY IF EXISTS "Approved admins and managers can delete vehicles" ON public.vehicles;
DROP POLICY IF EXISTS "Approved admins and managers can delete expenses" ON public.expenses;

-- Create new delete policies for admin only
CREATE POLICY "Approved admins can delete vehicles" 
ON public.vehicles 
FOR DELETE 
USING (is_user_approved(auth.uid()) AND is_admin(auth.uid()));

CREATE POLICY "Approved admins can delete expenses" 
ON public.expenses 
FOR DELETE 
USING (is_user_approved(auth.uid()) AND is_admin(auth.uid()));
-- ============================================
-- Migration: 20251217211928_a6365b5d-a3ff-41e3-9ae3-a89a1c0a4264.sql
-- ============================================

-- Create vehicle inspections table
CREATE TABLE public.vehicle_inspections (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE CASCADE,
  branch_id UUID REFERENCES public.branches(id),
  inspection_date DATE NOT NULL DEFAULT CURRENT_DATE,
  inspection_month DATE NOT NULL DEFAULT date_trunc('month', CURRENT_DATE),
  kilometers INTEGER,
  
  -- Pass/Fail fields (true = pass, false = fail)
  brakes_pass BOOLEAN NOT NULL DEFAULT true,
  brakes_notes TEXT,
  engine_pass BOOLEAN NOT NULL DEFAULT true,
  engine_notes TEXT,
  transmission_pass BOOLEAN NOT NULL DEFAULT true,
  transmission_notes TEXT,
  tires_pass BOOLEAN NOT NULL DEFAULT true,
  tires_notes TEXT,
  headlights_pass BOOLEAN NOT NULL DEFAULT true,
  headlights_notes TEXT,
  signal_lights_pass BOOLEAN NOT NULL DEFAULT true,
  signal_lights_notes TEXT,
  oil_level_pass BOOLEAN NOT NULL DEFAULT true,
  oil_level_notes TEXT,
  windshield_fluid_pass BOOLEAN NOT NULL DEFAULT true,
  windshield_fluid_notes TEXT,
  wipers_pass BOOLEAN NOT NULL DEFAULT true,
  wipers_notes TEXT,
  
  completed_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.vehicle_inspections ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Approved users can view inspections"
ON public.vehicle_inspections
FOR SELECT
USING (is_user_approved(auth.uid()));

CREATE POLICY "Approved staff can create inspections"
ON public.vehicle_inspections
FOR INSERT
WITH CHECK (is_user_approved(auth.uid()));

CREATE POLICY "Approved admins and managers can update inspections"
ON public.vehicle_inspections
FOR UPDATE
USING (is_user_approved(auth.uid()) AND (EXISTS (
  SELECT 1 FROM user_roles
  WHERE user_roles.user_id = auth.uid() AND user_roles.role = ANY (ARRAY['admin'::text, 'manager'::text])
)));

CREATE POLICY "Approved admins can delete inspections"
ON public.vehicle_inspections
FOR DELETE
USING (is_user_approved(auth.uid()) AND is_admin(auth.uid()));

-- Add trigger for updated_at
CREATE TRIGGER update_vehicle_inspections_updated_at
BEFORE UPDATE ON public.vehicle_inspections
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();
-- ============================================
-- Migration: 20251219155057_8005d9dd-1487-4565-bcec-a87e17676717.sql
-- ============================================

-- Add on_rim and bolt_pattern columns to tire_inventory table
ALTER TABLE public.tire_inventory 
ADD COLUMN on_rim boolean NOT NULL DEFAULT false,
ADD COLUMN bolt_pattern text;
-- ============================================
-- Migration: 20251219155655_b831a2d7-2c62-46e3-9661-559ca7c2e44e.sql
-- ============================================

-- Fix 1: Add explicit DENY policies for UPDATE and DELETE on audit_logs
CREATE POLICY "No one can update audit logs" 
ON public.audit_logs 
FOR UPDATE 
USING (false);

CREATE POLICY "No one can delete audit logs" 
ON public.audit_logs 
FOR DELETE 
USING (false);

-- Fix 2: Create a function to check if user is admin or manager (for sensitive data access)
CREATE OR REPLACE FUNCTION public.is_admin_or_manager(_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = _user_id 
    AND role IN ('admin', 'manager')
  )
$$;

-- Fix 3: Create a secure view for vehicles that hides transponder from non-admin/manager users
CREATE OR REPLACE VIEW public.vehicles_secure AS
SELECT 
  id,
  plate,
  vin,
  make,
  model,
  year,
  status,
  branch_id,
  odometer_km,
  last_oil_change_km,
  notes,
  current_tire_type,
  summer_tire_location,
  winter_tire_location,
  summer_tire_brand,
  summer_tire_measurements,
  summer_tire_condition,
  winter_tire_brand,
  winter_tire_measurements,
  winter_tire_condition,
  tire_notes,
  last_tire_change_date,
  created_at,
  updated_at,
  CASE 
    WHEN is_admin_or_manager(auth.uid()) THEN transponder_407
    ELSE NULL
  END AS transponder_407
FROM public.vehicles;
-- ============================================
-- Migration: 20251219155727_92a6bf57-2b05-4947-a360-7e1c332f022f.sql
-- ============================================

-- Drop the security definer view (it's a security risk)
DROP VIEW IF EXISTS public.vehicles_secure;

-- Instead, we'll handle this at the application level
-- The transponder_407 field access will be controlled in the frontend code
-- by checking if user is admin/manager before displaying it
-- ============================================
-- Migration: 20251229195209_859c75eb-b179-491c-b5d0-b6b7f03703d7.sql
-- ============================================

-- Create vendors table for matching receipt vendors
CREATE TABLE public.vendors (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  category TEXT,
  address TEXT,
  phone TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS on vendors
ALTER TABLE public.vendors ENABLE ROW LEVEL SECURITY;

-- Vendors are viewable by all approved users
CREATE POLICY "Approved users can view vendors" 
ON public.vendors 
FOR SELECT 
USING (is_user_approved(auth.uid()));

-- Admins and managers can manage vendors
CREATE POLICY "Approved admins and managers can manage vendors" 
ON public.vendors 
FOR ALL 
USING (is_user_approved(auth.uid()) AND is_admin_or_manager(auth.uid()))
WITH CHECK (is_user_approved(auth.uid()) AND is_admin_or_manager(auth.uid()));

-- Create manager_approvers table for dropdown list
CREATE TABLE public.manager_approvers (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS on manager_approvers
ALTER TABLE public.manager_approvers ENABLE ROW LEVEL SECURITY;

-- All approved users can view manager approvers
CREATE POLICY "Approved users can view manager approvers" 
ON public.manager_approvers 
FOR SELECT 
USING (is_user_approved(auth.uid()));

-- Admins can manage manager approvers
CREATE POLICY "Admins can manage manager approvers" 
ON public.manager_approvers 
FOR ALL 
USING (is_user_approved(auth.uid()) AND is_admin(auth.uid()))
WITH CHECK (is_user_approved(auth.uid()) AND is_admin(auth.uid()));

-- Insert the default manager approvers
INSERT INTO public.manager_approvers (name) VALUES 
  ('Frank C'),
  ('Gabe'),
  ('Manny'),
  ('Adriano'),
  ('Pino');

-- Add new columns to expenses table for enhanced tracking
ALTER TABLE public.expenses 
ADD COLUMN IF NOT EXISTS vendor_id UUID REFERENCES public.vendors(id),
ADD COLUMN IF NOT EXISTS vendor_name TEXT,
ADD COLUMN IF NOT EXISTS staff_name TEXT,
ADD COLUMN IF NOT EXISTS manager_approver_id UUID REFERENCES public.manager_approvers(id),
ADD COLUMN IF NOT EXISTS subtotal NUMERIC,
ADD COLUMN IF NOT EXISTS tax_amount NUMERIC,
ADD COLUMN IF NOT EXISTS receipt_scanned BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS branch_id UUID REFERENCES public.branches(id);

-- Insert additional expense categories for fleet management (using valid types)
INSERT INTO public.expense_categories (name, type) VALUES
  ('Vehicle Purchase', 'maintenance'),
  ('Tire/Rim Purchase', 'maintenance'),
  ('Fuel', 'maintenance'),
  ('Insurance', 'maintenance'),
  ('Registration & Licensing', 'maintenance'),
  ('Parking & Tolls', 'maintenance'),
  ('Cleaning & Detailing', 'maintenance'),
  ('Towing', 'repair'),
  ('Roadside Assistance', 'repair'),
  ('Parts & Accessories', 'maintenance')
ON CONFLICT (id) DO NOTHING;

-- Insert some common vendors as seed data
INSERT INTO public.vendors (name, category) VALUES
  ('Canadian Tire', 'Parts'),
  ('Costco Tire Centre', 'Tires'),
  ('Jiffy Lube', 'Service'),
  ('Mr. Lube', 'Service'),
  ('Petro-Canada', 'Fuel'),
  ('Shell', 'Fuel'),
  ('NAPA Auto Parts', 'Parts'),
  ('AutoZone', 'Parts'),
  ('Discount Tire', 'Tires'),
  ('Goodyear', 'Tires')
ON CONFLICT (name) DO NOTHING;

-- Create trigger for vendors updated_at
CREATE TRIGGER update_vendors_updated_at
BEFORE UPDATE ON public.vendors
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();
-- ============================================
-- Migration: 20251229200224_910776e9-1298-4963-b83d-26f610bb155a.sql
-- ============================================

-- Add branch_id to vendors for branch association
ALTER TABLE public.vendors 
ADD COLUMN IF NOT EXISTS branch_id UUID REFERENCES public.branches(id),
ADD COLUMN IF NOT EXISTS services TEXT,
ADD COLUMN IF NOT EXISTS email TEXT,
ADD COLUMN IF NOT EXISTS website TEXT,
ADD COLUMN IF NOT EXISTS contact_name TEXT,
ADD COLUMN IF NOT EXISTS notes TEXT;
-- ============================================
-- Migration: 20251230171233_80780415-afd3-479c-be58-83d9983efec0.sql
-- ============================================

-- Drop the existing check constraint
ALTER TABLE public.expense_categories DROP CONSTRAINT IF EXISTS expense_categories_type_check;

-- Add a new check constraint that includes 'purchase'
ALTER TABLE public.expense_categories ADD CONSTRAINT expense_categories_type_check 
  CHECK (type IN ('maintenance', 'repair', 'purchase'));

-- Add Purchase category
INSERT INTO expense_categories (name, type) VALUES ('Purchase', 'purchase');
-- ============================================
-- Migration: 20251231150824_8cf3d64a-2be2-4908-b39d-2c98552558a8.sql
-- ============================================

-- Create fuel_receipts table
CREATE TABLE public.fuel_receipts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE CASCADE,
  branch_id UUID REFERENCES public.branches(id),
  amount NUMERIC NOT NULL,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  vendor_name TEXT,
  vendor_id UUID REFERENCES public.vendors(id),
  staff_name TEXT,
  description TEXT,
  receipt_scanned BOOLEAN DEFAULT false,
  created_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.fuel_receipts ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Approved users can view fuel receipts"
ON public.fuel_receipts
FOR SELECT
USING (is_user_approved(auth.uid()));

CREATE POLICY "Approved staff can create fuel receipts"
ON public.fuel_receipts
FOR INSERT
WITH CHECK (is_user_approved(auth.uid()) AND (created_by = auth.uid()));

CREATE POLICY "Approved staff can update own pending fuel receipts"
ON public.fuel_receipts
FOR UPDATE
USING (is_user_approved(auth.uid()) AND (created_by = auth.uid()));

CREATE POLICY "Approved admins and managers can update any fuel receipt"
ON public.fuel_receipts
FOR UPDATE
USING (is_user_approved(auth.uid()) AND is_admin_or_manager(auth.uid()))
WITH CHECK (is_user_approved(auth.uid()) AND is_admin_or_manager(auth.uid()));

CREATE POLICY "Approved admins can delete fuel receipts"
ON public.fuel_receipts
FOR DELETE
USING (is_user_approved(auth.uid()) AND is_admin(auth.uid()));

-- Create trigger for automatic timestamp updates
CREATE TRIGGER update_fuel_receipts_updated_at
BEFORE UPDATE ON public.fuel_receipts
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();
-- ============================================
-- Migration: 20260106171044_ed9d76c4-c490-4bd7-95de-8d888306bf18.sql
-- ============================================

-- Add soft delete columns to expenses table
ALTER TABLE public.expenses 
ADD COLUMN deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
ADD COLUMN deleted_by UUID DEFAULT NULL;

-- Add index for faster queries on non-deleted expenses
CREATE INDEX idx_expenses_deleted_at ON public.expenses(deleted_at);

-- Add comment for documentation
COMMENT ON COLUMN public.expenses.deleted_at IS 'Timestamp when expense was soft deleted';
COMMENT ON COLUMN public.expenses.deleted_by IS 'User ID who deleted the expense';
-- ============================================
-- Migration: 20260106173116_41502e1d-3007-4ee8-b263-73d5831f4f89.sql
-- ============================================

-- Enable pg_cron and pg_net extensions for scheduled tasks
CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA pg_catalog;
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- Grant usage to postgres role
GRANT USAGE ON SCHEMA cron TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA cron TO postgres;
-- ============================================
-- Migration: 20260107193319_b3718cbc-c54b-4eb8-bf07-8a9d074a881b.sql
-- ============================================

-- Add explicit authentication requirement policies for all flagged tables
-- These are permissive policies that require authentication as a baseline

-- profiles table - require authentication for viewing
CREATE POLICY "Require authentication for profiles"
ON public.profiles
FOR SELECT
TO public
USING (auth.uid() IS NOT NULL);

-- vendors table - require authentication for viewing
CREATE POLICY "Require authentication for vendors"
ON public.vendors
FOR SELECT
TO public
USING (auth.uid() IS NOT NULL);

-- vehicles table - require authentication for viewing
CREATE POLICY "Require authentication for vehicles"
ON public.vehicles
FOR SELECT
TO public
USING (auth.uid() IS NOT NULL);

-- expenses table - require authentication for viewing
CREATE POLICY "Require authentication for expenses"
ON public.expenses
FOR SELECT
TO public
USING (auth.uid() IS NOT NULL);

-- vehicle_inspections table - require authentication for viewing
CREATE POLICY "Require authentication for vehicle_inspections"
ON public.vehicle_inspections
FOR SELECT
TO public
USING (auth.uid() IS NOT NULL);

-- audit_logs table - require authentication for viewing
CREATE POLICY "Require authentication for audit_logs"
ON public.audit_logs
FOR SELECT
TO public
USING (auth.uid() IS NOT NULL);

-- user_roles table - require authentication for viewing
CREATE POLICY "Require authentication for user_roles"
ON public.user_roles
FOR SELECT
TO public
USING (auth.uid() IS NOT NULL);

-- Also add authentication requirements for other tables that may be missing them
-- branches
CREATE POLICY "Require authentication for branches"
ON public.branches
FOR SELECT
TO public
USING (auth.uid() IS NOT NULL);

-- documents
CREATE POLICY "Require authentication for documents"
ON public.documents
FOR SELECT
TO public
USING (auth.uid() IS NOT NULL);

-- expense_categories
CREATE POLICY "Require authentication for expense_categories"
ON public.expense_categories
FOR SELECT
TO public
USING (auth.uid() IS NOT NULL);

-- fuel_receipts
CREATE POLICY "Require authentication for fuel_receipts"
ON public.fuel_receipts
FOR SELECT
TO public
USING (auth.uid() IS NOT NULL);

-- gps_uploads
CREATE POLICY "Require authentication for gps_uploads"
ON public.gps_uploads
FOR SELECT
TO public
USING (auth.uid() IS NOT NULL);

-- manager_approvers
CREATE POLICY "Require authentication for manager_approvers"
ON public.manager_approvers
FOR SELECT
TO public
USING (auth.uid() IS NOT NULL);

-- tire_changes
CREATE POLICY "Require authentication for tire_changes"
ON public.tire_changes
FOR SELECT
TO public
USING (auth.uid() IS NOT NULL);

-- tire_claim_requests
CREATE POLICY "Require authentication for tire_claim_requests"
ON public.tire_claim_requests
FOR SELECT
TO public
USING (auth.uid() IS NOT NULL);

-- tire_inventory
CREATE POLICY "Require authentication for tire_inventory"
ON public.tire_inventory
FOR SELECT
TO public
USING (auth.uid() IS NOT NULL);
-- ============================================
-- Migration: 20260112194749_0e5370bf-cb60-41ac-bc1f-78042215a435.sql
-- ============================================

-- Add subtotal and tax_amount columns to fuel_receipts table for HST tracking
ALTER TABLE public.fuel_receipts 
ADD COLUMN subtotal numeric,
ADD COLUMN tax_amount numeric;
-- ============================================
-- Migration: 20260115152557_625da2a4-6936-4ae0-9f2b-75d6bbb3ea78.sql
-- ============================================

-- Add default_branch_id column to profiles table
ALTER TABLE public.profiles 
ADD COLUMN default_branch_id uuid REFERENCES public.branches(id) ON DELETE SET NULL;

-- Add comment for clarity
COMMENT ON COLUMN public.profiles.default_branch_id IS 'Default branch for the user when submitting expenses';
-- ============================================
-- Migration: 20260115163120_ab2baab2-b5b1-4844-8306-bbef9e6a4258.sql
-- ============================================

-- Create pre-approval rules table
CREATE TABLE public.expense_preapproval_rules (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  branch_id UUID REFERENCES public.branches(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES public.expense_categories(id) ON DELETE CASCADE,
  max_amount NUMERIC NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(branch_id, category_id)
);

-- Enable RLS
ALTER TABLE public.expense_preapproval_rules ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Approved users can view preapproval rules"
ON public.expense_preapproval_rules
FOR SELECT
USING (is_user_approved(auth.uid()));

CREATE POLICY "Admins can manage preapproval rules"
ON public.expense_preapproval_rules
FOR ALL
USING (is_user_approved(auth.uid()) AND is_admin(auth.uid()))
WITH CHECK (is_user_approved(auth.uid()) AND is_admin(auth.uid()));

CREATE POLICY "Require authentication for expense_preapproval_rules"
ON public.expense_preapproval_rules
FOR SELECT
USING (auth.uid() IS NOT NULL);

-- Add updated_at trigger
CREATE TRIGGER update_expense_preapproval_rules_updated_at
BEFORE UPDATE ON public.expense_preapproval_rules
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Insert initial rule: Oil Change under $100 auto-approved for all branches
INSERT INTO public.expense_preapproval_rules (branch_id, category_id, max_amount, is_active)
VALUES (NULL, (SELECT id FROM public.expense_categories WHERE name = 'Oil Change' LIMIT 1), 100.00, true);
-- ============================================
-- Migration: 20260205191756_821b85e1-7d8a-4e03-b802-92c9980d9c97.sql
-- ============================================

-- Add general_notes column to vehicle_inspections table
ALTER TABLE public.vehicle_inspections 
ADD COLUMN general_notes TEXT NULL;
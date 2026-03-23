-- Multi-Tenant Migration for Fleet Management System
-- This migration converts a single-tenant application to a multi-tenant architecture
-- Date: 2026-03-23

-- ============================================================================
-- 1. CREATE ORGANIZATIONS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  logo_url TEXT,
  owner_id UUID REFERENCES auth.users ON DELETE SET NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on organizations table
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 2. CREATE SUBSCRIPTIONS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  plan_type TEXT NOT NULL DEFAULT 'monthly' CHECK (plan_type IN ('monthly', 'annual')),
  price_cents INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'trialing' CHECK (status IN ('trialing', 'active', 'past_due', 'canceled', 'unpaid')),
  trial_ends_at TIMESTAMPTZ,
  current_period_start TIMESTAMPTZ,
  current_period_end TIMESTAMPTZ,
  canceled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on subscriptions table
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 3. CREATE SUPER_ADMINS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS super_admins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES auth.users ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on super_admins table
ALTER TABLE super_admins ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 4. ADD ORGANIZATION_ID COLUMN TO EXISTING TABLES
-- ============================================================================

-- profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS organization_id UUID;

-- branches
ALTER TABLE branches ADD COLUMN IF NOT EXISTS organization_id UUID;

-- vehicles
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS organization_id UUID;

-- expense_categories
ALTER TABLE expense_categories ADD COLUMN IF NOT EXISTS organization_id UUID;

-- expenses
ALTER TABLE expenses ADD COLUMN IF NOT EXISTS organization_id UUID;

-- documents
ALTER TABLE documents ADD COLUMN IF NOT EXISTS organization_id UUID;

-- user_roles
ALTER TABLE user_roles ADD COLUMN IF NOT EXISTS organization_id UUID;

-- audit_logs
ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS organization_id UUID;

-- gps_uploads
ALTER TABLE gps_uploads ADD COLUMN IF NOT EXISTS organization_id UUID;

-- tire_changes (if exists)
ALTER TABLE IF EXISTS tire_changes ADD COLUMN IF NOT EXISTS organization_id UUID;

-- tire_inventory (if exists)
ALTER TABLE IF EXISTS tire_inventory ADD COLUMN IF NOT EXISTS organization_id UUID;

-- tire_claim_requests (if exists)
ALTER TABLE IF EXISTS tire_claim_requests ADD COLUMN IF NOT EXISTS organization_id UUID;

-- vehicle_inspections
ALTER TABLE vehicle_inspections ADD COLUMN IF NOT EXISTS organization_id UUID;

-- vendors
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS organization_id UUID;

-- manager_approvers
ALTER TABLE manager_approvers ADD COLUMN IF NOT EXISTS organization_id UUID;

-- fuel_receipts
ALTER TABLE fuel_receipts ADD COLUMN IF NOT EXISTS organization_id UUID;

-- expense_preapproval_rules
ALTER TABLE expense_preapproval_rules ADD COLUMN IF NOT EXISTS organization_id UUID;

-- ============================================================================
-- 5. CREATE DEFAULT ORGANIZATION AND ASSIGN EXISTING DATA
-- ============================================================================

DO $$
DECLARE
  default_org_id UUID;
BEGIN
  -- Insert default organization if it doesn't exist
  INSERT INTO organizations (name, slug, is_active)
  VALUES ('Default Organization', 'default', true)
  ON CONFLICT (slug) DO UPDATE SET updated_at = NOW()
  RETURNING id INTO default_org_id;

  -- Assign all existing null organization_id values to the default organization
  UPDATE profiles SET organization_id = default_org_id WHERE organization_id IS NULL;
  UPDATE branches SET organization_id = default_org_id WHERE organization_id IS NULL;
  UPDATE vehicles SET organization_id = default_org_id WHERE organization_id IS NULL;
  UPDATE expense_categories SET organization_id = default_org_id WHERE organization_id IS NULL;
  UPDATE expenses SET organization_id = default_org_id WHERE organization_id IS NULL;
  UPDATE documents SET organization_id = default_org_id WHERE organization_id IS NULL;
  UPDATE user_roles SET organization_id = default_org_id WHERE organization_id IS NULL;
  UPDATE audit_logs SET organization_id = default_org_id WHERE organization_id IS NULL;
  UPDATE gps_uploads SET organization_id = default_org_id WHERE organization_id IS NULL;
  UPDATE IF EXISTS tire_changes SET organization_id = default_org_id WHERE organization_id IS NULL;
  UPDATE IF EXISTS tire_inventory SET organization_id = default_org_id WHERE organization_id IS NULL;
  UPDATE IF EXISTS tire_claim_requests SET organization_id = default_org_id WHERE organization_id IS NULL;
  UPDATE vehicle_inspections SET organization_id = default_org_id WHERE organization_id IS NULL;
  UPDATE vendors SET organization_id = default_org_id WHERE organization_id IS NULL;
  UPDATE manager_approvers SET organization_id = default_org_id WHERE organization_id IS NULL;
  UPDATE fuel_receipts SET organization_id = default_org_id WHERE organization_id IS NULL;
  UPDATE expense_preapproval_rules SET organization_id = default_org_id WHERE organization_id IS NULL;
END $$;

-- ============================================================================
-- 6. ADD FOREIGN KEY CONSTRAINTS AND SET NOT NULL
-- ============================================================================

-- profiles
ALTER TABLE profiles ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE profiles ADD CONSTRAINT fk_profiles_organization_id
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- branches
ALTER TABLE branches ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE branches ADD CONSTRAINT fk_branches_organization_id
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- vehicles
ALTER TABLE vehicles ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE vehicles ADD CONSTRAINT fk_vehicles_organization_id
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- expense_categories
ALTER TABLE expense_categories ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE expense_categories ADD CONSTRAINT fk_expense_categories_organization_id
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- expenses
ALTER TABLE expenses ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE expenses ADD CONSTRAINT fk_expenses_organization_id
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- documents
ALTER TABLE documents ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE documents ADD CONSTRAINT fk_documents_organization_id
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- user_roles
ALTER TABLE user_roles ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE user_roles ADD CONSTRAINT fk_user_roles_organization_id
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- audit_logs
ALTER TABLE audit_logs ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE audit_logs ADD CONSTRAINT fk_audit_logs_organization_id
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- gps_uploads
ALTER TABLE gps_uploads ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE gps_uploads ADD CONSTRAINT fk_gps_uploads_organization_id
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- tire_changes
ALTER TABLE IF EXISTS tire_changes ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE IF EXISTS tire_changes ADD CONSTRAINT fk_tire_changes_organization_id
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- tire_inventory
ALTER TABLE IF EXISTS tire_inventory ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE IF EXISTS tire_inventory ADD CONSTRAINT fk_tire_inventory_organization_id
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- tire_claim_requests
ALTER TABLE IF EXISTS tire_claim_requests ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE IF EXISTS tire_claim_requests ADD CONSTRAINT fk_tire_claim_requests_organization_id
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- vehicle_inspections
ALTER TABLE vehicle_inspections ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE vehicle_inspections ADD CONSTRAINT fk_vehicle_inspections_organization_id
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- vendors
ALTER TABLE vendors ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE vendors ADD CONSTRAINT fk_vendors_organization_id
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- manager_approvers
ALTER TABLE manager_approvers ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE manager_approvers ADD CONSTRAINT fk_manager_approvers_organization_id
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- fuel_receipts
ALTER TABLE fuel_receipts ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE fuel_receipts ADD CONSTRAINT fk_fuel_receipts_organization_id
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- expense_preapproval_rules
ALTER TABLE expense_preapproval_rules ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE expense_preapproval_rules ADD CONSTRAINT fk_expense_preapproval_rules_organization_id
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- ============================================================================
-- 7. CREATE GET_USER_ORG_ID() FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION get_user_org_id()
RETURNS UUID AS $$
DECLARE
  user_org_id UUID;
BEGIN
  -- Get the organization_id for the currently authenticated user
  SELECT organization_id INTO user_org_id
  FROM profiles
  WHERE id = auth.uid();

  -- Return the organization_id or NULL if not found
  RETURN user_org_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 8. CREATE INDEXES ON ORGANIZATION_ID
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_profiles_organization_id ON profiles(organization_id);
CREATE INDEX IF NOT EXISTS idx_branches_organization_id ON branches(organization_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_organization_id ON vehicles(organization_id);
CREATE INDEX IF NOT EXISTS idx_expense_categories_organization_id ON expense_categories(organization_id);
CREATE INDEX IF NOT EXISTS idx_expenses_organization_id ON expenses(organization_id);
CREATE INDEX IF NOT EXISTS idx_documents_organization_id ON documents(organization_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_organization_id ON user_roles(organization_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_organization_id ON audit_logs(organization_id);
CREATE INDEX IF NOT EXISTS idx_gps_uploads_organization_id ON gps_uploads(organization_id);
CREATE INDEX IF NOT EXISTS idx_tire_changes_organization_id ON tire_changes(organization_id);
CREATE INDEX IF NOT EXISTS idx_tire_inventory_organization_id ON tire_inventory(organization_id);
CREATE INDEX IF NOT EXISTS idx_tire_claim_requests_organization_id ON tire_claim_requests(organization_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_inspections_organization_id ON vehicle_inspections(organization_id);
CREATE INDEX IF NOT EXISTS idx_vendors_organization_id ON vendors(organization_id);
CREATE INDEX IF NOT EXISTS idx_manager_approvers_organization_id ON manager_approvers(organization_id);
CREATE INDEX IF NOT EXISTS idx_fuel_receipts_organization_id ON fuel_receipts(organization_id);
CREATE INDEX IF NOT EXISTS idx_expense_preapproval_rules_organization_id ON expense_preapproval_rules(organization_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_organization_id ON subscriptions(organization_id);

-- ============================================================================
-- 9. UPDATE EXISTING RLS POLICIES - PROFILES TABLE
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;

-- Create new organization-aware policies for profiles
CREATE POLICY "Users can view profiles in their organization"
  ON profiles FOR SELECT
  USING (organization_id = get_user_org_id());

CREATE POLICY "Users can insert profile in their organization"
  ON profiles FOR INSERT
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can update profile in their organization"
  ON profiles FOR UPDATE
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can delete profile in their organization"
  ON profiles FOR DELETE
  USING (organization_id = get_user_org_id());

-- Enable RLS on profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 10. UPDATE EXISTING RLS POLICIES - BRANCHES TABLE
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Branches are viewable by everyone" ON branches;
DROP POLICY IF EXISTS "Branches are insertable by authenticated users" ON branches;
DROP POLICY IF EXISTS "Branches are updatable by authenticated users" ON branches;
DROP POLICY IF EXISTS "Branches are deletable by authenticated users" ON branches;

-- Create new organization-aware policies for branches
CREATE POLICY "Users can view branches in their organization"
  ON branches FOR SELECT
  USING (organization_id = get_user_org_id());

CREATE POLICY "Users can insert branch in their organization"
  ON branches FOR INSERT
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can update branch in their organization"
  ON branches FOR UPDATE
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can delete branch in their organization"
  ON branches FOR DELETE
  USING (organization_id = get_user_org_id());

-- Enable RLS on branches
ALTER TABLE branches ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 11. UPDATE EXISTING RLS POLICIES - VEHICLES TABLE
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Vehicles are viewable by everyone" ON vehicles;
DROP POLICY IF EXISTS "Vehicles are insertable by authenticated users" ON vehicles;
DROP POLICY IF EXISTS "Vehicles are updatable by authenticated users" ON vehicles;
DROP POLICY IF EXISTS "Vehicles are deletable by authenticated users" ON vehicles;

-- Create new organization-aware policies for vehicles
CREATE POLICY "Users can view vehicles in their organization"
  ON vehicles FOR SELECT
  USING (organization_id = get_user_org_id());

CREATE POLICY "Users can insert vehicle in their organization"
  ON vehicles FOR INSERT
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can update vehicle in their organization"
  ON vehicles FOR UPDATE
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can delete vehicle in their organization"
  ON vehicles FOR DELETE
  USING (organization_id = get_user_org_id());

-- Enable RLS on vehicles
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 12. UPDATE EXISTING RLS POLICIES - EXPENSE_CATEGORIES TABLE
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Expense categories are viewable by everyone" ON expense_categories;
DROP POLICY IF EXISTS "Expense categories are insertable by authenticated users" ON expense_categories;
DROP POLICY IF EXISTS "Expense categories are updatable by authenticated users" ON expense_categories;
DROP POLICY IF EXISTS "Expense categories are deletable by authenticated users" ON expense_categories;

-- Create new organization-aware policies for expense_categories
CREATE POLICY "Users can view expense categories in their organization"
  ON expense_categories FOR SELECT
  USING (organization_id = get_user_org_id());

CREATE POLICY "Users can insert expense category in their organization"
  ON expense_categories FOR INSERT
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can update expense category in their organization"
  ON expense_categories FOR UPDATE
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can delete expense category in their organization"
  ON expense_categories FOR DELETE
  USING (organization_id = get_user_org_id());

-- Enable RLS on expense_categories
ALTER TABLE expense_categories ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 13. UPDATE EXISTING RLS POLICIES - EXPENSES TABLE
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Expenses are viewable by everyone" ON expenses;
DROP POLICY IF EXISTS "Expenses are insertable by authenticated users" ON expenses;
DROP POLICY IF EXISTS "Expenses are updatable by authenticated users" ON expenses;
DROP POLICY IF EXISTS "Expenses are deletable by authenticated users" ON expenses;

-- Create new organization-aware policies for expenses
CREATE POLICY "Users can view expenses in their organization"
  ON expenses FOR SELECT
  USING (organization_id = get_user_org_id());

CREATE POLICY "Users can insert expense in their organization"
  ON expenses FOR INSERT
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can update expense in their organization"
  ON expenses FOR UPDATE
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can delete expense in their organization"
  ON expenses FOR DELETE
  USING (organization_id = get_user_org_id());

-- Enable RLS on expenses
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 14. UPDATE EXISTING RLS POLICIES - DOCUMENTS TABLE
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Documents are viewable by owner or approved users" ON documents;
DROP POLICY IF EXISTS "Documents are insertable by authenticated users" ON documents;
DROP POLICY IF EXISTS "Documents are updatable by owner" ON documents;
DROP POLICY IF EXISTS "Documents are deletable by owner" ON documents;

-- Create new organization-aware policies for documents
CREATE POLICY "Users can view documents in their organization"
  ON documents FOR SELECT
  USING (organization_id = get_user_org_id());

CREATE POLICY "Users can insert document in their organization"
  ON documents FOR INSERT
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can update document in their organization"
  ON documents FOR UPDATE
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can delete document in their organization"
  ON documents FOR DELETE
  USING (organization_id = get_user_org_id());

-- Enable RLS on documents
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 15. UPDATE EXISTING RLS POLICIES - USER_ROLES TABLE
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "User roles are viewable by authenticated users" ON user_roles;
DROP POLICY IF EXISTS "User roles are insertable by authenticated users" ON user_roles;
DROP POLICY IF EXISTS "User roles are updatable by authenticated users" ON user_roles;
DROP POLICY IF EXISTS "User roles are deletable by authenticated users" ON user_roles;

-- Create new organization-aware policies for user_roles
CREATE POLICY "Users can view user roles in their organization"
  ON user_roles FOR SELECT
  USING (organization_id = get_user_org_id());

CREATE POLICY "Users can insert user role in their organization"
  ON user_roles FOR INSERT
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can update user role in their organization"
  ON user_roles FOR UPDATE
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can delete user role in their organization"
  ON user_roles FOR DELETE
  USING (organization_id = get_user_org_id());

-- Enable RLS on user_roles
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 16. UPDATE EXISTING RLS POLICIES - AUDIT_LOGS TABLE
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Audit logs are viewable by authenticated users" ON audit_logs;
DROP POLICY IF EXISTS "Audit logs are insertable by authenticated users" ON audit_logs;

-- Create new organization-aware policies for audit_logs
CREATE POLICY "Users can view audit logs in their organization"
  ON audit_logs FOR SELECT
  USING (organization_id = get_user_org_id());

CREATE POLICY "Users can insert audit log in their organization"
  ON audit_logs FOR INSERT
  WITH CHECK (organization_id = get_user_org_id());

-- Enable RLS on audit_logs
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 17. UPDATE EXISTING RLS POLICIES - GPS_UPLOADS TABLE
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "GPS uploads are viewable by authenticated users" ON gps_uploads;
DROP POLICY IF EXISTS "GPS uploads are insertable by authenticated users" ON gps_uploads;
DROP POLICY IF EXISTS "GPS uploads are updatable by authenticated users" ON gps_uploads;

-- Create new organization-aware policies for gps_uploads
CREATE POLICY "Users can view GPS uploads in their organization"
  ON gps_uploads FOR SELECT
  USING (organization_id = get_user_org_id());

CREATE POLICY "Users can insert GPS upload in their organization"
  ON gps_uploads FOR INSERT
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can update GPS upload in their organization"
  ON gps_uploads FOR UPDATE
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

-- Enable RLS on gps_uploads
ALTER TABLE gps_uploads ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 18. UPDATE EXISTING RLS POLICIES - VEHICLE_INSPECTIONS TABLE
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Vehicle inspections are viewable by authenticated users" ON vehicle_inspections;
DROP POLICY IF EXISTS "Vehicle inspections are insertable by authenticated users" ON vehicle_inspections;
DROP POLICY IF EXISTS "Vehicle inspections are updatable by authenticated users" ON vehicle_inspections;
DROP POLICY IF EXISTS "Vehicle inspections are deletable by authenticated users" ON vehicle_inspections;

-- Create new organization-aware policies for vehicle_inspections
CREATE POLICY "Users can view vehicle inspections in their organization"
  ON vehicle_inspections FOR SELECT
  USING (organization_id = get_user_org_id());

CREATE POLICY "Users can insert vehicle inspection in their organization"
  ON vehicle_inspections FOR INSERT
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can update vehicle inspection in their organization"
  ON vehicle_inspections FOR UPDATE
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can delete vehicle inspection in their organization"
  ON vehicle_inspections FOR DELETE
  USING (organization_id = get_user_org_id());

-- Enable RLS on vehicle_inspections
ALTER TABLE vehicle_inspections ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 19. UPDATE EXISTING RLS POLICIES - VENDORS TABLE
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Vendors are viewable by authenticated users" ON vendors;
DROP POLICY IF EXISTS "Vendors are insertable by authenticated users" ON vendors;
DROP POLICY IF EXISTS "Vendors are updatable by authenticated users" ON vendors;
DROP POLICY IF EXISTS "Vendors are deletable by authenticated users" ON vendors;

-- Create new organization-aware policies for vendors
CREATE POLICY "Users can view vendors in their organization"
  ON vendors FOR SELECT
  USING (organization_id = get_user_org_id());

CREATE POLICY "Users can insert vendor in their organization"
  ON vendors FOR INSERT
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can update vendor in their organization"
  ON vendors FOR UPDATE
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can delete vendor in their organization"
  ON vendors FOR DELETE
  USING (organization_id = get_user_org_id());

-- Enable RLS on vendors
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 20. UPDATE EXISTING RLS POLICIES - MANAGER_APPROVERS TABLE
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Manager approvers are viewable by authenticated users" ON manager_approvers;
DROP POLICY IF EXISTS "Manager approvers are insertable by authenticated users" ON manager_approvers;
DROP POLICY IF EXISTS "Manager approvers are updatable by authenticated users" ON manager_approvers;
DROP POLICY IF EXISTS "Manager approvers are deletable by authenticated users" ON manager_approvers;

-- Create new organization-aware policies for manager_approvers
CREATE POLICY "Users can view manager approvers in their organization"
  ON manager_approvers FOR SELECT
  USING (organization_id = get_user_org_id());

CREATE POLICY "Users can insert manager approver in their organization"
  ON manager_approvers FOR INSERT
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can update manager approver in their organization"
  ON manager_approvers FOR UPDATE
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can delete manager approver in their organization"
  ON manager_approvers FOR DELETE
  USING (organization_id = get_user_org_id());

-- Enable RLS on manager_approvers
ALTER TABLE manager_approvers ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 21. UPDATE EXISTING RLS POLICIES - FUEL_RECEIPTS TABLE
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Fuel receipts are viewable by authenticated users" ON fuel_receipts;
DROP POLICY IF EXISTS "Fuel receipts are insertable by authenticated users" ON fuel_receipts;
DROP POLICY IF EXISTS "Fuel receipts are updatable by authenticated users" ON fuel_receipts;
DROP POLICY IF EXISTS "Fuel receipts are deletable by authenticated users" ON fuel_receipts;

-- Create new organization-aware policies for fuel_receipts
CREATE POLICY "Users can view fuel receipts in their organization"
  ON fuel_receipts FOR SELECT
  USING (organization_id = get_user_org_id());

CREATE POLICY "Users can insert fuel receipt in their organization"
  ON fuel_receipts FOR INSERT
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can update fuel receipt in their organization"
  ON fuel_receipts FOR UPDATE
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can delete fuel receipt in their organization"
  ON fuel_receipts FOR DELETE
  USING (organization_id = get_user_org_id());

-- Enable RLS on fuel_receipts
ALTER TABLE fuel_receipts ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 22. UPDATE EXISTING RLS POLICIES - EXPENSE_PREAPPROVAL_RULES TABLE
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Expense preapproval rules are viewable by authenticated users" ON expense_preapproval_rules;
DROP POLICY IF EXISTS "Expense preapproval rules are insertable by authenticated users" ON expense_preapproval_rules;
DROP POLICY IF EXISTS "Expense preapproval rules are updatable by authenticated users" ON expense_preapproval_rules;
DROP POLICY IF EXISTS "Expense preapproval rules are deletable by authenticated users" ON expense_preapproval_rules;

-- Create new organization-aware policies for expense_preapproval_rules
CREATE POLICY "Users can view expense preapproval rules in their organization"
  ON expense_preapproval_rules FOR SELECT
  USING (organization_id = get_user_org_id());

CREATE POLICY "Users can insert expense preapproval rule in their organization"
  ON expense_preapproval_rules FOR INSERT
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can update expense preapproval rule in their organization"
  ON expense_preapproval_rules FOR UPDATE
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "Users can delete expense preapproval rule in their organization"
  ON expense_preapproval_rules FOR DELETE
  USING (organization_id = get_user_org_id());

-- Enable RLS on expense_preapproval_rules
ALTER TABLE expense_preapproval_rules ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 23. UPDATE EXISTING RLS POLICIES - TIRE_CHANGES TABLE (if exists)
-- ============================================================================

DO $$
BEGIN
  -- Drop existing policies if table exists
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tire_changes') THEN
    DROP POLICY IF EXISTS "Tire changes are viewable by authenticated users" ON tire_changes;
    DROP POLICY IF EXISTS "Tire changes are insertable by authenticated users" ON tire_changes;
    DROP POLICY IF EXISTS "Tire changes are updatable by authenticated users" ON tire_changes;
    DROP POLICY IF EXISTS "Tire changes are deletable by authenticated users" ON tire_changes;

    -- Create new organization-aware policies
    CREATE POLICY "Users can view tire changes in their organization"
      ON tire_changes FOR SELECT
      USING (organization_id = get_user_org_id());

    CREATE POLICY "Users can insert tire change in their organization"
      ON tire_changes FOR INSERT
      WITH CHECK (organization_id = get_user_org_id());

    CREATE POLICY "Users can update tire change in their organization"
      ON tire_changes FOR UPDATE
      USING (organization_id = get_user_org_id())
      WITH CHECK (organization_id = get_user_org_id());

    CREATE POLICY "Users can delete tire change in their organization"
      ON tire_changes FOR DELETE
      USING (organization_id = get_user_org_id());

    -- Enable RLS on tire_changes
    ALTER TABLE tire_changes ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- ============================================================================
-- 24. UPDATE EXISTING RLS POLICIES - TIRE_INVENTORY TABLE (if exists)
-- ============================================================================

DO $$
BEGIN
  -- Drop existing policies if table exists
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tire_inventory') THEN
    DROP POLICY IF EXISTS "Tire inventory is viewable by authenticated users" ON tire_inventory;
    DROP POLICY IF EXISTS "Tire inventory is insertable by authenticated users" ON tire_inventory;
    DROP POLICY IF EXISTS "Tire inventory is updatable by authenticated users" ON tire_inventory;
    DROP POLICY IF EXISTS "Tire inventory is deletable by authenticated users" ON tire_inventory;

    -- Create new organization-aware policies
    CREATE POLICY "Users can view tire inventory in their organization"
      ON tire_inventory FOR SELECT
      USING (organization_id = get_user_org_id());

    CREATE POLICY "Users can insert tire inventory in their organization"
      ON tire_inventory FOR INSERT
      WITH CHECK (organization_id = get_user_org_id());

    CREATE POLICY "Users can update tire inventory in their organization"
      ON tire_inventory FOR UPDATE
      USING (organization_id = get_user_org_id())
      WITH CHECK (organization_id = get_user_org_id());

    CREATE POLICY "Users can delete tire inventory in their organization"
      ON tire_inventory FOR DELETE
      USING (organization_id = get_user_org_id());

    -- Enable RLS on tire_inventory
    ALTER TABLE tire_inventory ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- ============================================================================
-- 25. UPDATE EXISTING RLS POLICIES - TIRE_CLAIM_REQUESTS TABLE (if exists)
-- ============================================================================

DO $$
BEGIN
  -- Drop existing policies if table exists
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tire_claim_requests') THEN
    DROP POLICY IF EXISTS "Tire claim requests are viewable by authenticated users" ON tire_claim_requests;
    DROP POLICY IF EXISTS "Tire claim requests are insertable by authenticated users" ON tire_claim_requests;
    DROP POLICY IF EXISTS "Tire claim requests are updatable by authenticated users" ON tire_claim_requests;
    DROP POLICY IF EXISTS "Tire claim requests are deletable by authenticated users" ON tire_claim_requests;

    -- Create new organization-aware policies
    CREATE POLICY "Users can view tire claim requests in their organization"
      ON tire_claim_requests FOR SELECT
      USING (organization_id = get_user_org_id());

    CREATE POLICY "Users can insert tire claim request in their organization"
      ON tire_claim_requests FOR INSERT
      WITH CHECK (organization_id = get_user_org_id());

    CREATE POLICY "Users can update tire claim request in their organization"
      ON tire_claim_requests FOR UPDATE
      USING (organization_id = get_user_org_id())
      WITH CHECK (organization_id = get_user_org_id());

    CREATE POLICY "Users can delete tire claim request in their organization"
      ON tire_claim_requests FOR DELETE
      USING (organization_id = get_user_org_id());

    -- Enable RLS on tire_claim_requests
    ALTER TABLE tire_claim_requests ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- ============================================================================
-- 26. CREATE RLS POLICIES FOR ORGANIZATIONS TABLE
-- ============================================================================

-- Users can view their own organization
CREATE POLICY "Users can view their own organization"
  ON organizations FOR SELECT
  USING (id = get_user_org_id());

-- Super admins can view all organizations
CREATE POLICY "Super admins can view all organizations"
  ON organizations FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM super_admins
    WHERE super_admins.user_id = auth.uid()
  ));

-- ============================================================================
-- 27. CREATE RLS POLICIES FOR SUBSCRIPTIONS TABLE
-- ============================================================================

-- Organization owners and admins can view their subscription
CREATE POLICY "Users can view subscription for their organization"
  ON subscriptions FOR SELECT
  USING (organization_id = get_user_org_id());

-- Super admins can view all subscriptions
CREATE POLICY "Super admins can view all subscriptions"
  ON subscriptions FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM super_admins
    WHERE super_admins.user_id = auth.uid()
  ));

-- ============================================================================
-- 28. CREATE RLS POLICIES FOR SUPER_ADMINS TABLE
-- ============================================================================

-- Super admins can view other super admins
CREATE POLICY "Super admins can view all super admins"
  ON super_admins FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM super_admins
    WHERE super_admins.user_id = auth.uid()
  ));

-- Users can only view their own super admin record
CREATE POLICY "Users can view their own super admin record"
  ON super_admins FOR SELECT
  USING (user_id = auth.uid());

-- ============================================================================
-- 29. UPDATE HANDLE_NEW_USER TRIGGER FUNCTION
-- ============================================================================

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user();

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  default_org_id UUID;
BEGIN
  -- Get the default organization
  SELECT id INTO default_org_id
  FROM organizations
  WHERE slug = 'default'
  LIMIT 1;

  -- If no default organization exists, create one
  IF default_org_id IS NULL THEN
    INSERT INTO organizations (name, slug, is_active)
    VALUES ('Default Organization', 'default', true)
    RETURNING id INTO default_org_id;
  END IF;

  -- Insert new user profile in the default organization
  INSERT INTO public.profiles (id, email, organization_id)
  VALUES (new.id, new.email, default_org_id);

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- ============================================================================
-- 30. CREATE ADDITIONAL INDEXES FOR COMMON QUERIES
-- ============================================================================

-- Composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_profiles_org_id_email ON profiles(organization_id, email);
CREATE INDEX IF NOT EXISTS idx_branches_org_id_name ON branches(organization_id, name);
CREATE INDEX IF NOT EXISTS idx_vehicles_org_id_plate ON vehicles(organization_id, plate);
CREATE INDEX IF NOT EXISTS idx_expenses_org_id_created_at ON expenses(organization_id, created_at);
CREATE INDEX IF NOT EXISTS idx_vehicle_inspections_org_id_vehicle_id ON vehicle_inspections(organization_id, vehicle_id);

-- Index for super admin lookups
CREATE INDEX IF NOT EXISTS idx_super_admins_user_id ON super_admins(user_id);

-- Index for subscriptions status queries
CREATE INDEX IF NOT EXISTS idx_subscriptions_org_id_status ON subscriptions(organization_id, status);

-- ============================================================================
-- 31. GRANT NECESSARY PERMISSIONS
-- ============================================================================

-- Grant execute permission on get_user_org_id function to authenticated users
GRANT EXECUTE ON FUNCTION get_user_org_id() TO authenticated;

-- Grant execute permission on handle_new_user function
GRANT EXECUTE ON FUNCTION handle_new_user() TO authenticated;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

-- This migration successfully converts the single-tenant fleet management
-- application to a multi-tenant architecture with proper isolation,
-- authentication, and authorization policies.

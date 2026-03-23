import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { useToast } from '@/hooks/use-toast';
import { supabase } from '@/integrations/supabase/client';
import {
  Building2,
  Users,
  CreditCard,
  DollarSign,
  Plus,
  Search,
  Eye,
  Power,
  ChevronDown,
  ChevronUp,
} from 'lucide-react';
import { useAuth } from '@/hooks/useAuth';
import { format } from 'date-fns';

interface Organization {
  id: string;
  name: string;
  slug: string;
  is_active: boolean;
  created_at: string;
  owner_id: string | null;
  owner_email?: string;
  users_count?: number;
  vehicles_count?: number;
}

interface Subscription {
  id: string;
  organization_id: string;
  plan_type: string;
  price_cents: number;
  status: string;
  current_period_start: string | null;
  current_period_end: string | null;
}

interface ExpandedOrg {
  [key: string]: boolean;
}

const SuperAdmin = () => {
  const navigate = useNavigate();
  const { user, loading: authLoading } = useAuth();
  const { toast } = useToast();

  const [organizations, setOrganizations] = useState<Organization[]>([]);
  const [subscriptions, setSubscriptions] = useState<Map<string, Subscription>>(
    new Map()
  );
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [expandedOrgs, setExpandedOrgs] = useState<ExpandedOrg>({});
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
  const [isSuperAdmin, setIsSuperAdmin] = useState(false);

  // Form state for add organization dialog
  const [newOrgName, setNewOrgName] = useState('');
  const [newOrgSlug, setNewOrgSlug] = useState('');
  const [newOrgOwnerEmail, setNewOrgOwnerEmail] = useState('');
  const [isSubmittingOrg, setIsSubmittingOrg] = useState(false);

  useEffect(() => {
    if (!authLoading && !user) {
      navigate('/auth');
    }
  }, [user, authLoading, navigate]);

  // Check if user is super admin
  useEffect(() => {
    const checkSuperAdminStatus = async () => {
      if (!user) return;

      try {
        const { data, error } = await supabase
          .from('super_admins')
          .select('id')
          .eq('user_id', user.id)
          .single();

        if (error && error.code !== 'PGRST116') {
          console.error('Error checking super admin status:', error);
          throw error;
        }

        setIsSuperAdmin(!!data);
      } catch (error) {
        console.error('Error:', error);
        setIsSuperAdmin(false);
      }
    };

    checkSuperAdminStatus();
  }, [user]);

  // Fetch organizations and subscriptions
  useEffect(() => {
    if (isSuperAdmin) {
      fetchOrganizations();
    }
  }, [isSuperAdmin]);

  const fetchOrganizations = async () => {
    setLoading(true);
    try {
      // Fetch all organizations
      const { data: orgsData, error: orgsError } = await supabase
        .from('organizations')
        .select('id, name, slug, is_active, created_at, owner_id')
        .order('created_at', { ascending: false });

      if (orgsError) throw orgsError;

      // Fetch all subscriptions
      const { data: subsData, error: subsError } = await supabase
        .from('subscriptions')
        .select('id, organization_id, plan_type, price_cents, status, current_period_start, current_period_end');

      if (subsError) throw subsError;

      // Build subscriptions map
      const subsMap = new Map<string, Subscription>();
      if (subsData) {
        subsData.forEach((sub) => {
          subsMap.set(sub.organization_id, sub);
        });
      }
      setSubscriptions(subsMap);

      // For each organization, fetch owner email, user count, and vehicle count
      if (orgsData) {
        const enrichedOrgs = await Promise.all(
          orgsData.map(async (org) => {
            let ownerEmail = '';
            let usersCount = 0;
            let vehiclesCount = 0;

            // Get owner email
            if (org.owner_id) {
              try {
                const { data: ownerData, error: ownerError } = await supabase
                  .from('profiles')
                  .select('email')
                  .eq('id', org.owner_id)
                  .single();

                if (!ownerError && ownerData) {
                  ownerEmail = ownerData.email;
                }
              } catch (error) {
                console.error('Error fetching owner email:', error);
              }
            }

            // Get user count
            try {
              const { count: usersCountData, error: usersCountError } = await supabase
                .from('profiles')
                .select('id', { count: 'exact', head: true })
                .eq('organization_id', org.id);

              if (!usersCountError && usersCountData !== null) {
                usersCount = usersCountData;
              }
            } catch (error) {
              console.error('Error fetching users count:', error);
            }

            // Get vehicle count
            try {
              const { count: vehiclesCountData, error: vehiclesCountError } = await supabase
                .from('vehicles')
                .select('id', { count: 'exact', head: true })
                .eq('organization_id', org.id);

              if (!vehiclesCountError && vehiclesCountData !== null) {
                vehiclesCount = vehiclesCountData;
              }
            } catch (error) {
              console.error('Error fetching vehicles count:', error);
            }

            return {
              ...org,
              owner_email: ownerEmail,
              users_count: usersCount,
              vehicles_count: vehiclesCount,
            };
          })
        );

        setOrganizations(enrichedOrgs);
      }
    } catch (error) {
      console.error('Error fetching organizations:', error);
      toast({
        title: 'Error',
        description: 'Failed to load organizations',
        variant: 'destructive',
      });
    } finally {
      setLoading(false);
    }
  };

  const handleAddOrganization = async () => {
    if (!newOrgName.trim() || !newOrgSlug.trim() || !newOrgOwnerEmail.trim()) {
      toast({
        title: 'Validation Error',
        description: 'Please fill in all fields',
        variant: 'destructive',
      });
      return;
    }

    setIsSubmittingOrg(true);
    try {
      // Create organization
      const { data: newOrg, error: orgError } = await supabase
        .from('organizations')
        .insert({
          name: newOrgName,
          slug: newOrgSlug,
          is_active: true,
        })
        .select()
        .single();

      if (orgError) throw orgError;

      // Find or create user profile with owner email
      const { data: existingProfile, error: profileCheckError } = await supabase
        .from('profiles')
        .select('id')
        .eq('email', newOrgOwnerEmail)
        .single();

      if (!profileCheckError && existingProfile) {
        // Update existing profile to be part of this organization
        await supabase
          .from('profiles')
          .update({ organization_id: newOrg.id })
          .eq('id', existingProfile.id);
      } else {
        // In a real scenario, you'd send an invitation to create an account
        // For now, just log the action
        console.log(
          `Created organization. Invitation should be sent to: ${newOrgOwnerEmail}`
        );
      }

      // Reset form
      setNewOrgName('');
      setNewOrgSlug('');
      setNewOrgOwnerEmail('');
      setIsAddDialogOpen(false);

      toast({
        title: 'Success',
        description: `Organization "${newOrgName}" created successfully`,
      });

      // Refresh organizations
      fetchOrganizations();
    } catch (error) {
      console.error('Error creating organization:', error);
      toast({
        title: 'Error',
        description: 'Failed to create organization',
        variant: 'destructive',
      });
    } finally {
      setIsSubmittingOrg(false);
    }
  };

  const handleToggleActive = async (orgId: string, currentActive: boolean) => {
    try {
      const { error } = await supabase
        .from('organizations')
        .update({ is_active: !currentActive })
        .eq('id', orgId);

      if (error) throw error;

      toast({
        title: 'Success',
        description: `Organization ${!currentActive ? 'activated' : 'deactivated'}`,
      });

      fetchOrganizations();
    } catch (error) {
      console.error('Error toggling organization status:', error);
      toast({
        title: 'Error',
        description: 'Failed to update organization status',
        variant: 'destructive',
      });
    }
  };

  const handleImpersonate = (orgName: string) => {
    toast({
      title: 'Impersonate',
      description: `Logged in as admin for "${orgName}" (placeholder)`,
    });
  };

  const toggleExpanded = (orgId: string) => {
    setExpandedOrgs((prev) => ({
      ...prev,
      [orgId]: !prev[orgId],
    }));
  };

  // Calculate stats
  const totalOrganizations = organizations.length;
  const totalUsers = organizations.reduce(
    (sum, org) => sum + (org.users_count || 0),
    0
  );
  const activeSubscriptions = Array.from(subscriptions.values()).filter(
    (sub) => sub.status === 'active' || sub.status === 'trialing'
  ).length;
  const monthlyRevenue = Array.from(subscriptions.values())
    .filter((sub) => sub.status === 'active')
    .reduce((sum, sub) => sum + sub.price_cents / 100, 0);

  // Filter organizations by search
  const filteredOrganizations = organizations.filter((org) =>
    org.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  if (authLoading || loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  if (!isSuperAdmin) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <Card className="w-full max-w-md">
          <CardHeader>
            <CardTitle>Access Denied</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-gray-600 mb-4">
              You do not have permission to access the Super Admin dashboard.
            </p>
            <Button
              onClick={() => navigate('/')}
              className="w-full"
            >
              Go to Home
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-slate-900 text-white py-8 px-6 mb-8">
        <div className="max-w-7xl mx-auto">
          <h1 className="text-4xl font-bold mb-2">Super Admin Dashboard</h1>
          <p className="text-slate-300">
            Manage all organizations and subscriptions
          </p>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 pb-12">
        {/* Stats Overview */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">
                Total Organizations
              </CardTitle>
              <Building2 className="h-4 w-4 text-slate-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{totalOrganizations}</div>
              <p className="text-xs text-gray-600 mt-1">
                Active organizations
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Total Users</CardTitle>
              <Users className="h-4 w-4 text-slate-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{totalUsers}</div>
              <p className="text-xs text-gray-600 mt-1">
                Across all organizations
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">
                Active Subscriptions
              </CardTitle>
              <CreditCard className="h-4 w-4 text-slate-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{activeSubscriptions}</div>
              <p className="text-xs text-gray-600 mt-1">
                Active or trialing plans
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">
                Monthly Revenue
              </CardTitle>
              <DollarSign className="h-4 w-4 text-slate-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">
                ${monthlyRevenue.toFixed(2)}
              </div>
              <p className="text-xs text-gray-600 mt-1">
                From active subscriptions
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Organizations Table */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <div>
              <CardTitle>Organizations</CardTitle>
            </div>
            <Dialog open={isAddDialogOpen} onOpenChange={setIsAddDialogOpen}>
              <DialogTrigger asChild>
                <Button className="flex items-center gap-2">
                  <Plus className="h-4 w-4" />
                  Add Organization
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>Create New Organization</DialogTitle>
                </DialogHeader>
                <div className="space-y-4">
                  <div>
                    <Label htmlFor="org-name">Organization Name</Label>
                    <Input
                      id="org-name"
                      placeholder="e.g., Acme Corp"
                      value={newOrgName}
                      onChange={(e) => {
                        setNewOrgName(e.target.value);
                        // Auto-generate slug from name
                        setNewOrgSlug(
                          e.target.value
                            .toLowerCase()
                            .replace(/\s+/g, '-')
                            .replace(/[^a-z0-9-]/g, '')
                        );
                      }}
                      className="mt-1"
                    />
                  </div>
                  <div>
                    <Label htmlFor="org-slug">Slug</Label>
                    <Input
                      id="org-slug"
                      placeholder="e.g., acme-corp"
                      value={newOrgSlug}
                      onChange={(e) => setNewOrgSlug(e.target.value)}
                      className="mt-1"
                    />
                  </div>
                  <div>
                    <Label htmlFor="owner-email">Owner Email</Label>
                    <Input
                      id="owner-email"
                      type="email"
                      placeholder="owner@example.com"
                      value={newOrgOwnerEmail}
                      onChange={(e) => setNewOrgOwnerEmail(e.target.value)}
                      className="mt-1"
                    />
                  </div>
                  <div className="flex gap-2 justify-end pt-4">
                    <Button
                      variant="outline"
                      onClick={() => setIsAddDialogOpen(false)}
                      disabled={isSubmittingOrg}
                    >
                      Cancel
                    </Button>
                    <Button
                      onClick={handleAddOrganization}
                      disabled={isSubmittingOrg}
                    >
                      {isSubmittingOrg ? 'Creating...' : 'Create'}
                    </Button>
                  </div>
                </div>
              </DialogContent>
            </Dialog>
          </CardHeader>

          <CardContent>
            {/* Search */}
            <div className="mb-6">
              <div className="relative">
                <Search className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
                <Input
                  placeholder="Search organizations by name..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="pl-10"
                />
              </div>
            </div>

            {/* Organizations List */}
            <div className="space-y-2">
              {filteredOrganizations.length === 0 ? (
                <div className="text-center py-8 text-gray-500">
                  <p>No organizations found</p>
                </div>
              ) : (
                filteredOrganizations.map((org) => {
                  const isExpanded = expandedOrgs[org.id];
                  const subscription = subscriptions.get(org.id);

                  return (
                    <div
                      key={org.id}
                      className="border rounded-lg overflow-hidden"
                    >
                      {/* Main Row */}
                      <div className="bg-white p-4 flex items-center justify-between hover:bg-gray-50 cursor-pointer">
                        <div className="flex items-center gap-4 flex-1">
                          <button
                            onClick={() => toggleExpanded(org.id)}
                            className="p-1 hover:bg-gray-200 rounded"
                          >
                            {isExpanded ? (
                              <ChevronUp className="h-4 w-4" />
                            ) : (
                              <ChevronDown className="h-4 w-4" />
                            )}
                          </button>

                          <div className="flex-1">
                            <div className="flex items-center gap-3">
                              <h3 className="font-semibold">{org.name}</h3>
                              <Badge
                                variant={
                                  org.is_active ? 'default' : 'secondary'
                                }
                              >
                                {org.is_active ? 'Active' : 'Inactive'}
                              </Badge>
                              {subscription && (
                                <Badge
                                  variant={
                                    subscription.status === 'active'
                                      ? 'default'
                                      : subscription.status === 'trialing'
                                        ? 'outline'
                                        : 'secondary'
                                  }
                                >
                                  {subscription.status === 'active'
                                    ? 'Paid'
                                    : subscription.status === 'trialing'
                                      ? 'Trial'
                                      : subscription.status}
                                </Badge>
                              )}
                            </div>
                            <p className="text-sm text-gray-600 mt-1">
                              {org.owner_email} • {org.users_count || 0} users •{' '}
                              {org.vehicles_count || 0} vehicles
                            </p>
                          </div>
                        </div>

                        <div className="flex items-center gap-2">
                          <span className="text-xs text-gray-500">
                            {format(new Date(org.created_at), 'MMM d, yyyy')}
                          </span>
                        </div>
                      </div>

                      {/* Expanded Details */}
                      {isExpanded && (
                        <div className="bg-gray-50 border-t p-6 space-y-4">
                          <div className="grid grid-cols-2 md:grid-cols-3 gap-4 mb-6">
                            <div>
                              <p className="text-sm text-gray-600">Slug</p>
                              <p className="font-mono text-sm">{org.slug}</p>
                            </div>
                            <div>
                              <p className="text-sm text-gray-600">
                                Organization ID
                              </p>
                              <p className="font-mono text-xs text-gray-700">
                                {org.id.substring(0, 8)}...
                              </p>
                            </div>
                            <div>
                              <p className="text-sm text-gray-600">Created</p>
                              <p className="text-sm">
                                {format(new Date(org.created_at), 'MMM d, yyyy')}
                              </p>
                            </div>
                          </div>

                          {subscription && (
                            <div className="border-t pt-4">
                              <h4 className="font-semibold mb-3">
                                Subscription Details
                              </h4>
                              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                                <div>
                                  <p className="text-sm text-gray-600">
                                    Plan Type
                                  </p>
                                  <p className="text-sm capitalize">
                                    {subscription.plan_type}
                                  </p>
                                </div>
                                <div>
                                  <p className="text-sm text-gray-600">Status</p>
                                  <p className="text-sm capitalize">
                                    {subscription.status}
                                  </p>
                                </div>
                                <div>
                                  <p className="text-sm text-gray-600">Price</p>
                                  <p className="text-sm">
                                    ${(subscription.price_cents / 100).toFixed(2)}
                                  </p>
                                </div>
                                <div>
                                  <p className="text-sm text-gray-600">
                                    Billing Period
                                  </p>
                                  <p className="text-xs">
                                    {subscription.current_period_start
                                      ? format(
                                          new Date(
                                            subscription.current_period_start
                                          ),
                                          'MMM d'
                                        )
                                      : 'N/A'}
                                    {subscription.current_period_end && (
                                      <>
                                        {' '}
                                        -{' '}
                                        {format(
                                          new Date(
                                            subscription.current_period_end
                                          ),
                                          'MMM d, yyyy'
                                        )}
                                      </>
                                    )}
                                  </p>
                                </div>
                              </div>
                            </div>
                          )}

                          {/* Action Buttons */}
                          <div className="border-t pt-4 flex items-center gap-2">
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() =>
                                handleToggleActive(org.id, org.is_active)
                              }
                              className="flex items-center gap-2"
                            >
                              <Power className="h-4 w-4" />
                              {org.is_active ? 'Deactivate' : 'Activate'}
                            </Button>

                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => handleImpersonate(org.name)}
                              className="flex items-center gap-2"
                            >
                              <Eye className="h-4 w-4" />
                              Impersonate
                            </Button>
                          </div>
                        </div>
                      )}
                    </div>
                  );
                })
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default SuperAdmin;

import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Switch } from '@/components/ui/switch';
import { Check, Zap, Shield, Crown } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';
import { useAuth } from '@/hooks/useAuth';

const Pricing = () => {
  const [isAnnual, setIsAnnual] = useState(false);
  const [loading, setLoading] = useState(false);
  const { toast } = useToast();
  const { user } = useAuth();

  // Placeholder pricing
  const monthlyPrice = 99;
  const annualPrice = 891; // 25% discount
  const monthlySavings = (monthlyPrice * 12) - annualPrice;
  const discountPercent = 25;

  const features = [
    { name: 'Unlimited vehicles', icon: null },
    { name: 'Receipt scanning (AI-powered)', icon: null },
    { name: 'Multi-location management', icon: null },
    { name: 'Expense tracking & reporting', icon: null },
    { name: 'Tire management', icon: null },
    { name: 'Vehicle inspections', icon: null },
    { name: 'Team roles & permissions', icon: null },
    { name: 'Priority support', icon: null },
  ];

  const handleSubscribe = async (planType: 'monthly' | 'annual') => {
    setLoading(true);
    try {
      // Call Supabase edge function placeholder
      // const { data, error } = await supabase.functions.invoke('create-checkout-session', {
      //   body: { planType }
      // });

      // For now, show placeholder toast
      toast({
        title: 'Coming Soon',
        description: 'Stripe integration pending - supply your API keys to activate',
        variant: 'default',
      });
    } catch (error) {
      console.error('Subscription error:', error);
      toast({
        title: 'Error',
        description: 'Failed to initiate subscription. Please try again.',
        variant: 'destructive',
      });
    } finally {
      setLoading(false);
    }
  };

  const handleTrialStart = () => {
    toast({
      title: 'Free Trial',
      description: 'Starting your 14-day free trial. No credit card required.',
      variant: 'default',
    });
  };

  const handleContactSales = () => {
    toast({
      title: 'Contact Sales',
      description: 'Our sales team will reach out to you shortly.',
      variant: 'default',
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 py-12 px-4 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-7xl">
        {/* Header Section */}
        <div className="mb-12 text-center">
          <div className="mb-4 inline-flex items-center gap-2 rounded-full bg-blue-50 px-4 py-2">
            <Zap className="h-4 w-4 text-blue-600" />
            <span className="text-sm font-medium text-blue-700">Ease AI Fleet Manager</span>
          </div>
          <h1 className="mb-4 text-4xl font-bold text-slate-900 sm:text-5xl">
            Simple, Transparent Pricing
          </h1>
          <p className="mb-8 text-lg text-slate-600">
            One flat-rate plan designed for fleet managers of all sizes. Everything you need to manage your fleet efficiently.
          </p>

          {/* Billing Toggle */}
          <div className="mb-12 flex items-center justify-center gap-4">
            <span className={`text-sm font-medium ${!isAnnual ? 'text-slate-900' : 'text-slate-600'}`}>
              Monthly
            </span>
            <Switch
              checked={isAnnual}
              onCheckedChange={setIsAnnual}
              className="data-[state=checked]:bg-blue-600"
            />
            <span className={`text-sm font-medium ${isAnnual ? 'text-slate-900' : 'text-slate-600'}`}>
              Annual
            </span>
            {isAnnual && (
              <span className="ml-2 inline-flex items-center rounded-full bg-green-100 px-3 py-1 text-sm font-medium text-green-800">
                Save {discountPercent}%
              </span>
            )}
          </div>
        </div>

        {/* Pricing Card */}
        <div className="mx-auto max-w-2xl mb-12">
          <Card className="relative border-2 border-blue-200 bg-white shadow-lg hover:shadow-xl transition-all duration-300 overflow-hidden">
            {/* Ribbon Badge */}
            <div className="absolute -right-8 top-6 rotate-45 w-32 bg-blue-600 py-1 text-center text-white text-sm font-bold shadow-lg">
              Popular
            </div>

            <CardHeader className="pb-4">
              <div className="flex items-start justify-between">
                <div>
                  <CardTitle className="text-3xl">Professional Plan</CardTitle>
                  <CardDescription className="mt-2">Perfect for any fleet size</CardDescription>
                </div>
                <Crown className="h-8 w-8 text-blue-600" />
              </div>
            </CardHeader>

            <CardContent className="space-y-8">
              {/* Price Display */}
              <div className="space-y-2">
                <div className="flex items-baseline gap-2">
                  <span className="text-5xl font-bold text-slate-900">
                    ${isAnnual ? annualPrice : monthlyPrice}
                  </span>
                  <span className="text-lg text-slate-600">
                    {isAnnual ? '/year' : '/month'}
                  </span>
                </div>
                {isAnnual && (
                  <div className="flex items-center gap-2 rounded-lg bg-green-50 px-3 py-2 w-fit">
                    <Check className="h-4 w-4 text-green-600" />
                    <span className="text-sm font-medium text-green-700">
                      Save ${monthlySavings.toFixed(0)}/year
                    </span>
                  </div>
                )}
              </div>

              {/* Features List */}
              <div className="space-y-4">
                <h3 className="font-semibold text-slate-900">What's included:</h3>
                <ul className="space-y-3">
                  {features.map((feature, index) => (
                    <li key={index} className="flex items-start gap-3">
                      <Check className="h-5 w-5 flex-shrink-0 text-green-600 mt-0.5" />
                      <span className="text-slate-700">{feature.name}</span>
                    </li>
                  ))}
                </ul>
              </div>

              {/* CTA Buttons */}
              <div className="space-y-3 pt-4 border-t border-slate-200">
                <Button
                  onClick={() => handleSubscribe(isAnnual ? 'annual' : 'monthly')}
                  disabled={loading}
                  className="w-full h-11 bg-blue-600 hover:bg-blue-700 text-white font-semibold text-base"
                >
                  {loading ? 'Processing...' : 'Subscribe Now'}
                </Button>
                <Button
                  onClick={handleTrialStart}
                  variant="outline"
                  className="w-full h-11 border-slate-300 text-slate-700 hover:bg-slate-50 font-medium"
                >
                  Start Free 14-Day Trial
                </Button>
              </div>

              {/* Additional Info */}
              <div className="flex items-center justify-between rounded-lg bg-slate-50 px-4 py-3 text-sm text-slate-600">
                <span>No credit card required for trial</span>
                <a
                  href="#"
                  onClick={(e) => {
                    e.preventDefault();
                    handleContactSales();
                  }}
                  className="font-medium text-blue-600 hover:text-blue-700 underline"
                >
                  Contact Sales
                </a>
              </div>
            </CardContent>
          </Card>

          {/* Current Plan Badge */}
          {user && (
            <div className="mt-6 text-center">
              <div className="inline-flex items-center gap-2 rounded-full bg-blue-50 px-4 py-2 text-sm">
                <Shield className="h-4 w-4 text-blue-600" />
                <span className="text-blue-700 font-medium">Current Plan Active</span>
              </div>
            </div>
          )}
        </div>

        {/* FAQ / Info Section */}
        <div className="mx-auto max-w-2xl mt-16">
          <div className="text-center mb-8">
            <h2 className="text-2xl font-bold text-slate-900">Everything You Need</h2>
            <p className="mt-2 text-slate-600">
              Our comprehensive suite of fleet management tools helps you streamline operations and maximize efficiency.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <Card className="border-slate-200 bg-white">
              <CardHeader>
                <Zap className="h-8 w-8 text-blue-600 mb-2" />
                <CardTitle className="text-lg">AI-Powered Scanning</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-slate-600">
                  Automatically extract expense data from receipts using advanced AI technology.
                </p>
              </CardContent>
            </Card>

            <Card className="border-slate-200 bg-white">
              <CardHeader>
                <Shield className="h-8 w-8 text-blue-600 mb-2" />
                <CardTitle className="text-lg">Advanced Controls</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-slate-600">
                  Manage team permissions and set pre-approval rules for expense management.
                </p>
              </CardContent>
            </Card>

            <Card className="border-slate-200 bg-white">
              <CardHeader>
                <Crown className="h-8 w-8 text-blue-600 mb-2" />
                <CardTitle className="text-lg">Priority Support</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-slate-600">
                  Get dedicated support from our team to help you succeed with the platform.
                </p>
              </CardContent>
            </Card>
          </div>
        </div>

        {/* Trust Badges */}
        <div className="mx-auto max-w-2xl mt-12 text-center">
          <p className="mb-6 text-sm text-slate-600">Trusted by fleet managers worldwide</p>
          <div className="flex items-center justify-center gap-8 flex-wrap">
            <div className="flex items-center gap-2 text-slate-600">
              <Check className="h-4 w-4 text-green-600" />
              <span className="text-sm">Secure & Encrypted</span>
            </div>
            <div className="flex items-center gap-2 text-slate-600">
              <Check className="h-4 w-4 text-green-600" />
              <span className="text-sm">GDPR Compliant</span>
            </div>
            <div className="flex items-center gap-2 text-slate-600">
              <Check className="h-4 w-4 text-green-600" />
              <span className="text-sm">99.9% Uptime SLA</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Pricing;

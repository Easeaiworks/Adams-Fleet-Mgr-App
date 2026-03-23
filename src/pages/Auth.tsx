import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/hooks/useAuth';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { useToast } from '@/hooks/use-toast';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { supabase } from '@/integrations/supabase/client';
import {
  AlertDialog,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import { Truck, Car, Shield } from 'lucide-react';

const Auth = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [fullName, setFullName] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [showForgotPassword, setShowForgotPassword] = useState(false);
  const [showPendingApproval, setShowPendingApproval] = useState(false);
  const [activeTab, setActiveTab] = useState('signin');
  const { signIn, signUp, user } = useAuth();
  const navigate = useNavigate();
  const { toast } = useToast();

  useEffect(() => {
    if (user) {
      navigate('/');
    }
  }, [user, navigate]);

  const handleSignIn = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    const { error } = await signIn(email, password);

    if (error) {
      toast({
        title: 'Error',
        description: error.message,
        variant: 'destructive',
      });
      setIsLoading(false);
      return;
    }

    const { data: { user: authUser } } = await supabase.auth.getUser();
    if (authUser) {
      const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('is_approved, is_blocked')
        .eq('id', authUser.id)
        .single();

      if (!profile || profileError) {
        await supabase.auth.signOut();
        toast({
          title: 'Account Not Found',
          description: 'Your account profile does not exist. Please sign up again or contact an administrator.',
          variant: 'destructive',
        });
        setIsLoading(false);
        return;
      }

      if (profile.is_blocked) {
        await supabase.auth.signOut();
        toast({
          title: 'Access Denied',
          description: 'Your account has been blocked. Please contact an administrator if you believe this is an error.',
          variant: 'destructive',
        });
        setIsLoading(false);
        return;
      }

      if (!profile.is_approved) {
        await supabase.auth.signOut();
        toast({
          title: 'Account Pending Approval',
          description: 'Your account is awaiting admin approval. Please contact an administrator.',
          variant: 'destructive',
        });
        setIsLoading(false);
        return;
      }
    }

    toast({
      title: 'Success',
      description: 'Signed in successfully',
    });
    navigate('/');
  };

  const handleSignUp = async (e: React.FormEvent) => {
    e.preventDefault();

    if (password !== confirmPassword) {
      toast({
        title: 'Error',
        description: 'Passwords do not match',
        variant: 'destructive',
      });
      return;
    }

    if (password.length < 6) {
      toast({
        title: 'Error',
        description: 'Password must be at least 6 characters',
        variant: 'destructive',
      });
      return;
    }

    setIsLoading(true);

    const { error } = await signUp(email, password, fullName);

    if (error) {
      if (error.message?.includes('already registered') || error.message?.includes('already exists')) {
        toast({
          title: 'Account Already Exists',
          description: 'An account with this email already exists. Please sign in instead, or use "Forgot Password" if you need to reset your password.',
          variant: 'destructive',
        });
        setActiveTab('signin');
      } else {
        toast({
          title: 'Error',
          description: error.message,
          variant: 'destructive',
        });
      }
    } else {
      await supabase.auth.signOut();
      setEmail('');
      setPassword('');
      setConfirmPassword('');
      setFullName('');
      setShowPendingApproval(true);
    }

    setIsLoading(false);
  };

  const handleForgotPassword = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!email) {
      toast({
        title: 'Error',
        description: 'Please enter your email address',
        variant: 'destructive',
      });
      return;
    }

    setIsLoading(true);

    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/auth?reset=true`,
    });

    if (error) {
      toast({
        title: 'Error',
        description: error.message,
        variant: 'destructive',
      });
    } else {
      toast({
        title: 'Password Reset Email Sent',
        description: 'Check your email for a link to reset your password. It may take a few minutes to arrive.',
      });
      setShowForgotPassword(false);
    }

    setIsLoading(false);
  };

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    if (params.get('reset') === 'true') {
      toast({
        title: 'Set New Password',
        description: 'You can now set a new password below.',
      });
    }
  }, [toast]);

  const LogoSection = () => (
    <div className="flex flex-col items-center mb-2">
      <div className="relative mb-4">
        <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-blue-500 to-blue-700 flex items-center justify-center shadow-lg shadow-blue-500/30 animate-scale-in">
          <Truck className="w-10 h-10 text-white" />
        </div>
        <div className="absolute -bottom-1 -right-1 w-8 h-8 rounded-lg bg-gradient-to-br from-sky-400 to-blue-500 flex items-center justify-center shadow-md">
          <Car className="w-4 h-4 text-white" />
        </div>
      </div>
    </div>
  );

  const FeatureBadges = () => (
    <div className="flex flex-wrap justify-center gap-2 mt-4 mb-2">
      <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-medium bg-blue-50 text-blue-700 border border-blue-200">
        <Truck className="w-3 h-3" /> Fleet Tracking
      </span>
      <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-medium bg-emerald-50 text-emerald-700 border border-emerald-200">
        <Shield className="w-3 h-3" /> Enterprise Security
      </span>
      <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-medium bg-violet-50 text-violet-700 border border-violet-200">
        <Car className="w-3 h-3" /> Vehicle Management
      </span>
    </div>
  );

  if (showForgotPassword) {
    return (
      <div className="min-h-screen min-h-[100dvh] flex flex-col overflow-y-auto relative" style={{
        background: 'linear-gradient(135deg, #0f172a 0%, #1e3a5f 25%, #1e40af 50%, #3b82f6 75%, #0ea5e9 100%)'
      }}>
        {/* Animated background shapes */}
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <div className="absolute top-[-10%] left-[-5%] w-72 h-72 bg-blue-400/10 rounded-full blur-3xl animate-pulse" />
          <div className="absolute bottom-[-10%] right-[-5%] w-96 h-96 bg-sky-400/10 rounded-full blur-3xl animate-pulse" style={{ animationDelay: '1s' }} />
          <div className="absolute top-[40%] right-[10%] w-48 h-48 bg-indigo-400/10 rounded-full blur-2xl animate-pulse" style={{ animationDelay: '2s' }} />
        </div>

        <div className="flex-1 flex items-center justify-center p-4 py-8 relative z-10">
          <Card className="w-full max-w-md my-auto border-0 shadow-2xl shadow-black/20 animate-fade-in" style={{
            background: 'rgba(255, 255, 255, 0.95)',
            backdropFilter: 'blur(20px)',
          }}>
            <CardHeader className="space-y-1 pb-4">
              <LogoSection />
              <CardTitle className="text-2xl font-bold text-center bg-gradient-to-r from-blue-700 to-blue-500 bg-clip-text text-transparent">Reset Password</CardTitle>
              <CardDescription className="text-center text-slate-500">
                Enter your email and we'll send you a link to reset your password
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleForgotPassword} className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="reset-email" className="text-slate-700 font-medium">Email</Label>
                  <Input
                    id="reset-email"
                    type="email"
                    placeholder="your.email@company.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                    className="h-11 border-slate-200 focus:border-blue-500 focus:ring-blue-500/20 transition-all"
                  />
                </div>
                <Button type="submit" className="w-full h-11 bg-gradient-to-r from-blue-600 to-blue-500 hover:from-blue-700 hover:to-blue-600 shadow-lg shadow-blue-500/25 transition-all duration-200 hover:shadow-blue-500/40" disabled={isLoading}>
                  {isLoading ? 'Sending...' : 'Send Reset Link'}
                </Button>
                <Button
                  type="button"
                  variant="ghost"
                  className="w-full text-slate-500 hover:text-slate-700"
                  onClick={() => setShowForgotPassword(false)}
                >
                  Back to Sign In
                </Button>
              </form>
            </CardContent>
          </Card>
        </div>
        <footer className="py-4 text-center relative z-10">
          <p className="text-sm text-blue-200/60">Powered by Ease AI Works</p>
        </footer>
      </div>
    );
  }

  return (
    <div className="min-h-screen min-h-[100dvh] flex flex-col overflow-y-auto relative" style={{
      background: 'linear-gradient(135deg, #0f172a 0%, #1e3a5f 25%, #1e40af 50%, #3b82f6 75%, #0ea5e9 100%)'
    }}>
      {/* Animated background shapes */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-[-10%] left-[-5%] w-72 h-72 bg-blue-400/10 rounded-full blur-3xl animate-pulse" />
        <div className="absolute bottom-[-10%] right-[-5%] w-96 h-96 bg-sky-400/10 rounded-full blur-3xl animate-pulse" style={{ animationDelay: '1s' }} />
        <div className="absolute top-[40%] right-[10%] w-48 h-48 bg-indigo-400/10 rounded-full blur-2xl animate-pulse" style={{ animationDelay: '2s' }} />
        <div className="absolute top-[20%] left-[15%] w-32 h-32 bg-cyan-400/8 rounded-full blur-2xl animate-pulse" style={{ animationDelay: '3s' }} />
      </div>

      <div className="flex-1 flex items-center justify-center p-4 py-8 relative z-10">
        <Card className="w-full max-w-md my-auto border-0 shadow-2xl shadow-black/20 animate-fade-in" style={{
          background: 'rgba(255, 255, 255, 0.95)',
          backdropFilter: 'blur(20px)',
        }}>
          <CardHeader className="space-y-1 pb-2">
            <LogoSection />
            <CardTitle className="text-3xl font-bold text-center bg-gradient-to-r from-blue-700 to-blue-500 bg-clip-text text-transparent">
              Ease AI Fleet Mgr
            </CardTitle>
            <CardDescription className="text-center text-slate-500">
              Manage your vehicle fleet efficiently
            </CardDescription>
            <FeatureBadges />
          </CardHeader>
          <CardContent>
            <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
              <TabsList className="grid w-full grid-cols-2 bg-slate-100/80 p-1 rounded-lg">
                <TabsTrigger value="signin" className="rounded-md data-[state=active]:bg-white data-[state=active]:shadow-sm data-[state=active]:text-blue-700 font-medium transition-all">Sign In</TabsTrigger>
                <TabsTrigger value="signup" className="rounded-md data-[state=active]:bg-white data-[state=active]:shadow-sm data-[state=active]:text-blue-700 font-medium transition-all">Sign Up</TabsTrigger>
              </TabsList>

              <TabsContent value="signin">
                <form onSubmit={handleSignIn} className="space-y-4 mt-4">
                  <div className="space-y-2">
                    <Label htmlFor="email" className="text-slate-700 font-medium">Email</Label>
                    <Input
                      id="email"
                      type="email"
                      placeholder="your.email@company.com"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      required
                      className="h-11 border-slate-200 focus:border-blue-500 focus:ring-blue-500/20 transition-all"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="password" className="text-slate-700 font-medium">Password</Label>
                    <Input
                      id="password"
                      type="password"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      required
                      className="h-11 border-slate-200 focus:border-blue-500 focus:ring-blue-500/20 transition-all"
                    />
                  </div>
                  <Button type="submit" className="w-full h-11 bg-gradient-to-r from-blue-600 to-blue-500 hover:from-blue-700 hover:to-blue-600 shadow-lg shadow-blue-500/25 transition-all duration-200 hover:shadow-blue-500/40 font-semibold" disabled={isLoading}>
                    {isLoading ? 'Signing in...' : 'Sign In'}
                  </Button>
                  <Button
                    type="button"
                    variant="link"
                    className="w-full text-sm text-slate-400 hover:text-blue-600 transition-colors"
                    onClick={() => setShowForgotPassword(true)}
                  >
                    Forgot your password?
                  </Button>
                </form>
              </TabsContent>

              <TabsContent value="signup">
                <form onSubmit={handleSignUp} className="space-y-4 mt-4">
                  <div className="space-y-2">
                    <Label htmlFor="fullname" className="text-slate-700 font-medium">Full Name</Label>
                    <Input
                      id="fullname"
                      type="text"
                      placeholder="John Doe"
                      value={fullName}
                      onChange={(e) => setFullName(e.target.value)}
                      required
                      className="h-11 border-slate-200 focus:border-blue-500 focus:ring-blue-500/20 transition-all"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="signup-email" className="text-slate-700 font-medium">Email</Label>
                    <Input
                      id="signup-email"
                      type="email"
                      placeholder="your.email@company.com"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      required
                      className="h-11 border-slate-200 focus:border-blue-500 focus:ring-blue-500/20 transition-all"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="signup-password" className="text-slate-700 font-medium">Password</Label>
                    <Input
                      id="signup-password"
                      type="password"
                      placeholder="At least 6 characters"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      required
                      minLength={6}
                      className="h-11 border-slate-200 focus:border-blue-500 focus:ring-blue-500/20 transition-all"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="confirm-password" className="text-slate-700 font-medium">Confirm Password</Label>
                    <Input
                      id="confirm-password"
                      type="password"
                      placeholder="Re-enter your password"
                      value={confirmPassword}
                      onChange={(e) => setConfirmPassword(e.target.value)}
                      required
                      minLength={6}
                      className="h-11 border-slate-200 focus:border-blue-500 focus:ring-blue-500/20 transition-all"
                    />
                  </div>
                  <Button type="submit" className="w-full h-11 bg-gradient-to-r from-blue-600 to-blue-500 hover:from-blue-700 hover:to-blue-600 shadow-lg shadow-blue-500/25 transition-all duration-200 hover:shadow-blue-500/40 font-semibold" disabled={isLoading}>
                    {isLoading ? 'Creating account...' : 'Create Account'}
                  </Button>
                </form>
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>
      </div>
      <footer className="py-4 text-center relative z-10">
        <p className="text-sm text-blue-200/60">Powered by Ease AI Works</p>
      </footer>

      {/* Pending Approval Dialog */}
      <AlertDialog open={showPendingApproval} onOpenChange={setShowPendingApproval}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Request Submitted</AlertDialogTitle>
            <AlertDialogDescription className="space-y-2">
              <p>Your request for access has been submitted successfully.</p>
              <p>Please contact your Digital Administrator to approve your account before you can sign in.</p>
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <Button onClick={() => setShowPendingApproval(false)}>
              Understood
            </Button>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
};

export default Auth;

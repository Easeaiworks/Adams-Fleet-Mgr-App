import { ReactNode } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/hooks/useAuth';
import { Button } from '@/components/ui/button';
import { LogOut, Truck, Car } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';
import { Navigation } from './Navigation';

interface LayoutProps {
  children: ReactNode;
}

export function Layout({ children }: LayoutProps) {
  const { signOut, user } = useAuth();
  const navigate = useNavigate();
  const { toast } = useToast();

  const handleSignOut = async () => {
    const { error } = await signOut();
    if (!error) {
      toast({
        title: 'Signed out',
        description: 'You have been signed out successfully',
      });
      navigate('/auth');
    }
  };

  return (
    <div className="min-h-screen bg-background flex flex-col">
      <header className="border-b border-blue-700/30 bg-gradient-to-r from-blue-800 via-blue-600 to-blue-500 text-white sticky top-0 z-50 shadow-lg">
        {/* Top row: Branding and User Info */}
        <div className="container mx-auto px-4 py-4 flex items-center justify-between border-b border-white/20">
          <div className="cursor-pointer transition-transform duration-300 hover:scale-105 flex items-center gap-3" onClick={() => navigate('/')}>
            <div className="relative">
              <div className="w-10 h-10 rounded-xl bg-white/20 backdrop-blur-sm flex items-center justify-center shadow-md border border-white/30">
                <Truck className="w-5 h-5 text-white" />
              </div>
              <div className="absolute -bottom-0.5 -right-0.5 w-4 h-4 rounded-md bg-white/30 flex items-center justify-center border border-white/20">
                <Car className="w-2.5 h-2.5 text-white" />
              </div>
            </div>
            <div>
              <h1 className="text-2xl font-bold text-white">Ease AI Fleet Mgr</h1>
              <p className="text-xs text-blue-200">Vehicle Management System</p>
            </div>
          </div>
          <div className="flex items-center gap-4">
            {user && (
              <>
                <div className="text-right hidden sm:block">
                  <p className="text-sm font-semibold text-white">{user.email}</p>
                  <p className="text-xs text-blue-200">Fleet Manager</p>
                </div>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={handleSignOut}
                  className="gap-2 transition-all duration-200 border-white/40 text-white bg-white/15 hover:bg-white/25 hover:text-white"
                >
                  <LogOut className="h-4 w-4" />
                  Sign Out
                </Button>
              </>
            )}
          </div>
        </div>
        {/* Bottom row: Navigation */}
        <div className="container mx-auto px-4 py-3">
          <Navigation />
        </div>
      </header>
      <main className="container mx-auto px-4 py-8 flex-1 animate-fade-in">
        {children}
      </main>
      <footer className="border-t bg-card py-6 mt-12">
        <div className="container mx-auto px-4 text-center">
          <p className="text-sm text-muted-foreground">Powered by Ease AI Works</p>
        </div>
      </footer>
    </div>
  );
}

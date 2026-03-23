import { ReactNode } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/hooks/useAuth';
import { Button } from '@/components/ui/button';
import { LogOut } from 'lucide-react';
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
      <header className="border-b bg-gradient-to-r from-primary via-secondary to-accent/80 text-white sticky top-0 z-50 shadow-md backdrop-blur-sm bg-white/95 text-foreground border-border/40">
        {/* Top row: Branding and User Info */}
        <div className="container mx-auto px-4 py-4 flex items-center justify-between border-b border-white/20">
          <div className="cursor-pointer transition-transform duration-300 hover:scale-105" onClick={() => navigate('/')}>
            <h1 className="text-2xl font-bold bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">CHC Fleet Manager</h1>
            <p className="text-xs text-muted-foreground">Vehicle Management System</p>
          </div>
          <div className="flex items-center gap-4">
            {user && (
              <>
                <div className="text-right hidden sm:block">
                  <p className="text-sm font-semibold text-foreground">{user.email}</p>
                  <p className="text-xs text-muted-foreground">Fleet Manager</p>
                </div>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={handleSignOut}
                  className="gap-2 transition-all duration-200"
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
          <p className="text-sm text-muted-foreground">Powered by Refinish AI</p>
        </div>
      </footer>
    </div>
  );
}

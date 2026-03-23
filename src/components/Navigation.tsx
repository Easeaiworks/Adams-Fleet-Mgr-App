import { useLocation, useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Home, BarChart3, CheckSquare, Settings, CircleDot, ClipboardCheck, Receipt } from 'lucide-react';
import { useUserRole } from '@/hooks/useUserRole';
import { FuelReceiptDialog } from './FuelReceiptDialog';

export function Navigation() {
  const location = useLocation();
  const navigate = useNavigate();
  const { isAdmin, isAdminOrManager } = useUserRole();

  const isActive = (path: string) => location.pathname === path;

  const navClass = (path: string) =>
    `gap-2 px-3 relative transition-all duration-200 hover:scale-105 ${
      isActive(path)
        ? 'bg-white/25 text-white font-semibold border-b-2 border-white shadow-[0_0_12px_rgba(255,255,255,0.3)] hover:bg-white/35 hover:text-white'
        : 'text-white/70 hover:bg-white/10 hover:text-white'
    }`;

  return (
    <nav className="flex items-center gap-2 flex-wrap">
      <Button
        variant="ghost"
        size="sm"
        onClick={() => navigate('/')}
        className={navClass('/')}
      >
        <Home className="h-4 w-4" />
        Dashboard
      </Button>
      <Button
        variant="ghost"
        size="sm"
        onClick={() => navigate('/inspections')}
        className={navClass('/inspections')}
      >
        <ClipboardCheck className="h-4 w-4" />
        Inspections
      </Button>
      <Button
        variant="ghost"
        size="sm"
        onClick={() => navigate('/tires')}
        className={navClass('/tires')}
      >
        <CircleDot className="h-4 w-4" />
        Tires
      </Button>
      <Button
        variant="ghost"
        size="sm"
        onClick={() => navigate('/reports')}
        className={navClass('/reports')}
      >
        <BarChart3 className="h-4 w-4" />
        Reports
      </Button>
      <Button
        variant="ghost"
        size="sm"
        onClick={() => navigate('/expenses')}
        className={navClass('/expenses')}
      >
        <Receipt className="h-4 w-4" />
        Expenses
      </Button>

      {/* Fuel Receipt Quick Action */}
      <FuelReceiptDialog />

      {isAdminOrManager && (
        <Button
          variant="ghost"
          size="sm"
          onClick={() => navigate('/approvals')}
          className={navClass('/approvals')}
        >
          <CheckSquare className="h-4 w-4" />
          Approvals
        </Button>
      )}
      {isAdminOrManager && (
        <Button
          variant="ghost"
          size="sm"
          onClick={() => navigate('/admin')}
          className={navClass('/admin')}
        >
          <Settings className="h-4 w-4" />
          Admin
        </Button>
      )}
    </nav>
  );
}

import { useLocation, useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Home, BarChart3, CheckSquare, Settings, CircleDot, ClipboardCheck, Receipt } from 'lucide-react';
import { useUserRole } from '@/hooks/useUserRole';
import { FuelReceiptDialog } from './FuelReceiptDialog';

export function Navigation() {
  const location = useLocation();
  const navigate = useNavigate();
  const { isAdmin, isAdminOrManager } = useUserRole();

  return (
    <nav className="flex items-center gap-2 flex-wrap">
      <Button
        variant={location.pathname === '/' ? 'secondary' : 'ghost'}
        size="sm"
        onClick={() => navigate('/')}
        className={`gap-2 px-3 relative transition-all duration-200 hover:scale-105 ${
          location.pathname === '/' ? 'border-b-2 border-secondary' : ''
        }`}
      >
        <Home className="h-4 w-4" />
        Dashboard
      </Button>
      <Button
        variant={location.pathname === '/inspections' ? 'secondary' : 'ghost'}
        size="sm"
        onClick={() => navigate('/inspections')}
        className={`gap-2 px-3 relative transition-all duration-200 hover:scale-105 ${
          location.pathname === '/inspections' ? 'border-b-2 border-secondary' : ''
        }`}
      >
        <ClipboardCheck className="h-4 w-4" />
        Inspections
      </Button>
      <Button
        variant={location.pathname === '/tires' ? 'secondary' : 'ghost'}
        size="sm"
        onClick={() => navigate('/tires')}
        className={`gap-2 px-3 relative transition-all duration-200 hover:scale-105 ${
          location.pathname === '/tires' ? 'border-b-2 border-secondary' : ''
        }`}
      >
        <CircleDot className="h-4 w-4" />
        Tires
      </Button>
      <Button
        variant={location.pathname === '/reports' ? 'secondary' : 'ghost'}
        size="sm"
        onClick={() => navigate('/reports')}
        className={`gap-2 px-3 relative transition-all duration-200 hover:scale-105 ${
          location.pathname === '/reports' ? 'border-b-2 border-secondary' : ''
        }`}
      >
        <BarChart3 className="h-4 w-4" />
        Reports
      </Button>
      <Button
        variant={location.pathname === '/expenses' ? 'secondary' : 'ghost'}
        size="sm"
        onClick={() => navigate('/expenses')}
        className={`gap-2 px-3 relative transition-all duration-200 hover:scale-105 ${
          location.pathname === '/expenses' ? 'border-b-2 border-secondary' : ''
        }`}
      >
        <Receipt className="h-4 w-4" />
        Expenses
      </Button>

      {/* Fuel Receipt Quick Action */}
      <FuelReceiptDialog />

      {isAdminOrManager && (
        <Button
          variant={location.pathname === '/approvals' ? 'secondary' : 'ghost'}
          size="sm"
          onClick={() => navigate('/approvals')}
          className={`gap-2 px-3 relative transition-all duration-200 hover:scale-105 ${
            location.pathname === '/approvals' ? 'border-b-2 border-secondary' : ''
          }`}
        >
          <CheckSquare className="h-4 w-4" />
          Approvals
        </Button>
      )}
      {isAdminOrManager && (
        <Button
          variant={location.pathname === '/admin' ? 'secondary' : 'ghost'}
          size="sm"
          onClick={() => navigate('/admin')}
          className={`gap-2 px-3 relative transition-all duration-200 hover:scale-105 ${
            location.pathname === '/admin' ? 'border-b-2 border-secondary' : ''
          }`}
        >
          <Settings className="h-4 w-4" />
          Admin
        </Button>
      )}
    </nav>
  );
}

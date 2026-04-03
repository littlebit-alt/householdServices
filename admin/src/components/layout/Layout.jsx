import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { LayoutDashboard, Users, Briefcase, CalendarCheck, Tag, Wrench, Settings, LogOut } from 'lucide-react';
import useAuthStore from '../../store/authStore';

const navItems = [
  { to: '/', icon: LayoutDashboard, label: 'Dashboard' },
  { to: '/users', icon: Users, label: 'Users' },
  { to: '/providers', icon: Briefcase, label: 'Providers' },
  { to: '/bookings', icon: CalendarCheck, label: 'Bookings' },
  { to: '/categories', icon: Tag, label: 'Categories' },
  { to: '/services', icon: Wrench, label: 'Services' },
  { to: '/settings', icon: Settings, label: 'Settings' },
];

export default function Layout() {
  const admin = useAuthStore((state) => state.admin);
  const logout = useAuthStore((state) => state.logout);
  const navigate = useNavigate();

  return (
    <div className="flex h-screen bg-[#0d1117]">
      <aside className="w-52 bg-[#0d1117] border-r border-[#2d333b] flex flex-col">
        {/* Logo */}
        <div className="px-4 py-4 border-b border-[#2d333b]">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-[#20c9c9] bg-opacity-10 border border-[#20c9c9] border-opacity-30 flex items-center justify-center text-sm">🏠</div>
            <div>
              <p className="text-[#cdd9e5] font-semibold text-sm leading-none">HouseServ</p>
              <p className="text-[#20c9c9] text-xs mt-0.5">Admin Panel</p>
            </div>
          </div>
        </div>

        {/* Nav */}
        <nav className="flex-1 px-2 py-3 space-y-0.5">
          {navItems.map(({ to, icon: Icon, label }) => (
            <NavLink
              key={to}
              to={to}
              end={to === '/'}
              className={({ isActive }) =>
                `flex items-center gap-2.5 px-3 py-2 rounded-md text-sm transition-all ${
                  isActive
                    ? 'bg-[#20c9c9] bg-opacity-10 text-[#20c9c9] border border-[#20c9c9] border-opacity-20'
                    : 'text-[#8b949e] hover:text-[#cdd9e5] hover:bg-[#161b22]'
                }`
              }
            >
              <Icon size={15} />
              <span>{label}</span>
            </NavLink>
          ))}
        </nav>

        {/* User */}
        <div className="px-3 py-3 border-t border-[#2d333b]">
          <div className="flex items-center gap-2.5">
            <div className="w-7 h-7 rounded-full bg-[#20c9c9] bg-opacity-20 border border-[#20c9c9] border-opacity-30 flex items-center justify-center text-xs font-bold text-[#20c9c9]">
              {admin?.fullName?.charAt(0)}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-[#cdd9e5] text-xs font-medium truncate">{admin?.fullName}</p>
              <p className="text-[#8b949e] text-xs truncate">{admin?.email}</p>
            </div>
            <button
              onClick={() => { logout(); navigate('/login'); }}
              className="text-[#8b949e] hover:text-red-400 transition-colors p-1"
            >
              <LogOut size={13} />
            </button>
          </div>
        </div>
      </aside>

      {/* Main */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Top bar */}
        <div className="h-12 border-b border-[#2d333b] flex items-center px-6 gap-3">
          <div className="flex-1"/>
          <div className="w-2 h-2 rounded-full bg-[#20c9c9] animate-pulse"/>
          <span className="text-[#8b949e] text-xs">Live</span>
        </div>
        <main className="flex-1 overflow-auto">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
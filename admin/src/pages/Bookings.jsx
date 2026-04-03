import { useEffect, useState } from 'react';
import { Search } from 'lucide-react';
import api from '../services/api';
import toast from 'react-hot-toast';

const statusStyle = {
  PENDING: 'bg-yellow-400 bg-opacity-10 text-yellow-400 border-yellow-400 border-opacity-20',
  CONFIRMED: 'bg-blue-400 bg-opacity-10 text-blue-400 border-blue-400 border-opacity-20',
  ONGOING: 'bg-purple-400 bg-opacity-10 text-purple-400 border-purple-400 border-opacity-20',
  COMPLETED: 'bg-[#20c9c9] bg-opacity-10 text-[#20c9c9] border-[#20c9c9] border-opacity-20',
  CANCELLED: 'bg-red-400 bg-opacity-10 text-red-400 border-red-400 border-opacity-20',
};

export default function Bookings() {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');

  const fetchBookings = async () => {
    try { const r = await api.get('/bookings/all'); setBookings(r.data.bookings); }
    catch { toast.error('Failed to fetch bookings'); }
    finally { setLoading(false); }
  };

  useEffect(() => { fetchBookings(); }, []);

  const handleStatus = async (id, status) => {
    try { await api.put(`/bookings/${id}/status`, { status }); toast.success('Updated!'); fetchBookings(); }
    catch { toast.error('Failed'); }
  };

  const filtered = bookings.filter(b => {
    const s = search.toLowerCase();
    return (!statusFilter || b.status === statusFilter) &&
      (b.user.fullName.toLowerCase().includes(s) || b.service.name.toLowerCase().includes(s) || b.provider.fullName.toLowerCase().includes(s));
  });

  return (
    <div className="p-6 space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-lg font-semibold text-[#cdd9e5]">Bookings</h1>
          <p className="text-sm text-[#8b949e]">{bookings.length} total bookings</p>
        </div>
        <div className="flex items-center gap-3">
          <select value={statusFilter} onChange={e => setStatusFilter(e.target.value)}
            className="px-3 py-2 text-sm bg-[#161b22] border border-[#2d333b] rounded-md text-[#8b949e] focus:outline-none focus:border-[#20c9c9]">
            <option value="">All Status</option>
            {['PENDING','CONFIRMED','ONGOING','COMPLETED','CANCELLED'].map(s => <option key={s} value={s}>{s}</option>)}
          </select>
          <div className="relative">
            <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#8b949e]"/>
            <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search..."
              className="pl-9 pr-4 py-2 text-sm bg-[#161b22] border border-[#2d333b] rounded-md text-[#cdd9e5] placeholder-[#8b949e] focus:outline-none focus:border-[#20c9c9] w-48"/>
          </div>
        </div>
      </div>

      <div className="bg-[#161b22] border border-[#2d333b] rounded-lg overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-[#2d333b]">
              {['#','Client','Provider','Service','Price','Date','Status','Action'].map(h => (
                <th key={h} className="px-4 py-3 text-left text-xs font-medium text-[#8b949e] uppercase tracking-wider">{h}</th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-[#21262d]">
            {loading && <tr><td colSpan={8} className="px-5 py-8 text-center"><div className="w-5 h-5 border-2 border-[#20c9c9] border-t-transparent rounded-full animate-spin mx-auto"/></td></tr>}
            {!loading && filtered.length === 0 && <tr><td colSpan={8} className="px-5 py-8 text-center text-[#8b949e]">No bookings found</td></tr>}
            {filtered.map(b => (
              <tr key={b.id} className="hover:bg-[#1c2128] transition-colors">
                <td className="px-4 py-3 text-[#8b949e] text-xs">#{b.id}</td>
                <td className="px-4 py-3 font-medium text-[#cdd9e5]">{b.user.fullName}</td>
                <td className="px-4 py-3 text-[#8b949e]">{b.provider.fullName}</td>
                <td className="px-4 py-3 text-[#8b949e]">{b.service.name}</td>
                <td className="px-4 py-3 font-semibold text-[#20c9c9]">${b.totalPrice}</td>
                <td className="px-4 py-3 text-xs text-[#8b949e]">{new Date(b.scheduledAt).toLocaleDateString()}</td>
                <td className="px-4 py-3">
                  <span className={`text-xs px-2 py-1 rounded-full border ${statusStyle[b.status]}`}>{b.status}</span>
                </td>
                <td className="px-4 py-3">
                  <select value={b.status} onChange={e => handleStatus(b.id, e.target.value)}
                    className="text-xs bg-[#0d1117] border border-[#2d333b] rounded-md px-2 py-1 text-[#8b949e] focus:outline-none focus:border-[#20c9c9]">
                    {['PENDING','CONFIRMED','ONGOING','COMPLETED','CANCELLED'].map(s => <option key={s} value={s}>{s}</option>)}
                  </select>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
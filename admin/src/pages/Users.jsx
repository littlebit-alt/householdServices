import { useEffect, useState } from 'react';
import { Search, ToggleLeft, ToggleRight, Trash2, UserCheck, UserX } from 'lucide-react';
import api from '../services/api';
import toast from 'react-hot-toast';

export default function Users() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  const fetchUsers = async () => {
    try { const r = await api.get('/admin/users'); setUsers(r.data.users); }
    catch { toast.error('Failed to fetch users'); }
    finally { setLoading(false); }
  };

  useEffect(() => { fetchUsers(); }, []);

  const handleToggle = async (id) => {
    try { const r = await api.put(`/admin/users/${id}/toggle-status`); toast.success(r.data.message); fetchUsers(); }
    catch { toast.error('Failed to update'); }
  };

  const handleDelete = async (id) => {
    if (!confirm('Delete this user?')) return;
    try { await api.delete(`/admin/users/${id}`); toast.success('Deleted'); fetchUsers(); }
    catch { toast.error('Failed to delete'); }
  };

  const filtered = users.filter(u =>
    u.fullName.toLowerCase().includes(search.toLowerCase()) ||
    u.email.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="p-6 space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-lg font-semibold text-[#cdd9e5]">Users</h1>
          <p className="text-sm text-[#8b949e]">{users.length} registered clients</p>
        </div>
        <div className="relative">
          <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#8b949e]" />
          <input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search users..."
            className="pl-9 pr-4 py-2 text-sm bg-[#161b22] border border-[#2d333b] rounded-md text-[#cdd9e5] placeholder-[#8b949e] focus:outline-none focus:border-[#20c9c9] w-52"
          />
        </div>
      </div>

      <div className="bg-[#161b22] border border-[#2d333b] rounded-lg overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-[#2d333b]">
              {['User', 'Phone', 'Bookings', 'Status', 'Joined', 'Actions'].map(h => (
                <th key={h} className="px-5 py-3 text-left text-xs font-medium text-[#8b949e] uppercase tracking-wider">{h}</th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-[#21262d]">
            {loading && <tr><td colSpan={6} className="px-5 py-8 text-center text-[#8b949e]"><div className="w-5 h-5 border-2 border-[#20c9c9] border-t-transparent rounded-full animate-spin mx-auto"/></td></tr>}
            {!loading && filtered.length === 0 && <tr><td colSpan={6} className="px-5 py-8 text-center text-[#8b949e]">No users found</td></tr>}
            {filtered.map(user => (
              <tr key={user.id} className="hover:bg-[#1c2128] transition-colors">
                <td className="px-5 py-3">
                  <div className="flex items-center gap-3">
                    <div className="w-7 h-7 rounded-full bg-[#20c9c9] bg-opacity-10 border border-[#20c9c9] border-opacity-20 flex items-center justify-center text-xs font-bold text-[#20c9c9]">
                      {user.fullName.charAt(0)}
                    </div>
                    <div>
                      <p className="font-medium text-[#cdd9e5]">{user.fullName}</p>
                      <p className="text-xs text-[#8b949e]">{user.email}</p>
                    </div>
                  </div>
                </td>
                <td className="px-5 py-3 text-[#8b949e]">{user.phone}</td>
                <td className="px-5 py-3 text-[#cdd9e5]">{user._count.bookings}</td>
                <td className="px-5 py-3">
                  <span className={`text-xs font-medium px-2 py-1 rounded-full border ${user.isActive ? 'bg-[#20c9c9] bg-opacity-10 text-[#20c9c9] border-[#20c9c9] border-opacity-20' : 'bg-red-400 bg-opacity-10 text-red-400 border-red-400 border-opacity-20'}`}>
                    {user.isActive ? 'Active' : 'Inactive'}
                  </span>
                </td>
                <td className="px-5 py-3 text-xs text-[#8b949e]">{new Date(user.createdAt).toLocaleDateString()}</td>
                <td className="px-5 py-3">
                  <div className="flex items-center gap-2">
                    <button onClick={() => handleToggle(user.id)} className="text-[#8b949e] hover:text-[#20c9c9] transition-colors">
                      {user.isActive ? <ToggleRight size={18}/> : <ToggleLeft size={18}/>}
                    </button>
                    <button onClick={() => handleDelete(user.id)} className="text-[#8b949e] hover:text-red-400 transition-colors">
                      <Trash2 size={15}/>
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
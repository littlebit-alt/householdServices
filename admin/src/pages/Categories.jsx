import { useEffect, useState } from 'react';
import { Plus, Pencil, Trash2 } from 'lucide-react';
import api from '../services/api';
import toast from 'react-hot-toast';

export default function Categories() {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({ name: '', icon: '', description: '' });

  const fetchCategories = async () => {
    try { const r = await api.get('/categories'); setCategories(r.data.categories); }
    catch { toast.error('Failed'); }
    finally { setLoading(false); }
  };

  useEffect(() => { fetchCategories(); }, []);

  const openCreate = () => { setEditing(null); setForm({ name: '', icon: '', description: '' }); setShowModal(true); };
  const openEdit = (c) => { setEditing(c); setForm({ name: c.name, icon: c.icon || '', description: c.description || '' }); setShowModal(true); };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (editing) { await api.put(`/categories/${editing.id}`, form); toast.success('Updated!'); }
      else { await api.post('/categories', form); toast.success('Created!'); }
      setShowModal(false); fetchCategories();
    } catch (err) { toast.error(err.response?.data?.message || 'Failed'); }
  };

  const handleDelete = async (id) => {
    if (!confirm('Delete?')) return;
    try { await api.delete(`/categories/${id}`); toast.success('Deleted'); fetchCategories(); }
    catch { toast.error('Failed'); }
  };

  return (
    <div className="p-6 space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-lg font-semibold text-[#cdd9e5]">Categories</h1>
          <p className="text-sm text-[#8b949e]">{categories.length} categories</p>
        </div>
        <button onClick={openCreate} className="flex items-center gap-2 px-3 py-2 bg-[#20c9c9] bg-opacity-10 border border-[#20c9c9] border-opacity-30 text-[#20c9c9] text-sm rounded-md hover:bg-opacity-20 transition-colors">
          <Plus size={14}/> Add Category
        </button>
      </div>

      <div className="bg-[#161b22] border border-[#2d333b] rounded-lg overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-[#2d333b]">
              {['Icon','Name','Description','Services','Status','Actions'].map(h => (
                <th key={h} className="px-5 py-3 text-left text-xs font-medium text-[#8b949e] uppercase tracking-wider">{h}</th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-[#21262d]">
            {loading && <tr><td colSpan={6} className="px-5 py-8 text-center"><div className="w-5 h-5 border-2 border-[#20c9c9] border-t-transparent rounded-full animate-spin mx-auto"/></td></tr>}
            {categories.map(c => (
              <tr key={c.id} className="hover:bg-[#1c2128] transition-colors">
                <td className="px-5 py-3 text-xl">{c.icon}</td>
                <td className="px-5 py-3 font-medium text-[#cdd9e5]">{c.name}</td>
                <td className="px-5 py-3 text-xs text-[#8b949e]">{c.description || '—'}</td>
                <td className="px-5 py-3 text-[#cdd9e5]">{c._count.services}</td>
                <td className="px-5 py-3">
                  <span className={`text-xs px-2 py-1 rounded-full border ${c.isActive ? 'bg-[#20c9c9] bg-opacity-10 text-[#20c9c9] border-[#20c9c9] border-opacity-20' : 'bg-red-400 bg-opacity-10 text-red-400 border-red-400 border-opacity-20'}`}>
                    {c.isActive ? 'Active' : 'Inactive'}
                  </span>
                </td>
                <td className="px-5 py-3">
                  <div className="flex items-center gap-2">
                    <button onClick={() => openEdit(c)} className="text-[#8b949e] hover:text-[#20c9c9] transition-colors"><Pencil size={14}/></button>
                    <button onClick={() => handleDelete(c.id)} className="text-[#8b949e] hover:text-red-400 transition-colors"><Trash2 size={14}/></button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-60 flex items-center justify-center z-50">
          <div className="bg-[#161b22] border border-[#2d333b] rounded-lg p-6 w-full max-w-md">
            <h2 className="text-base font-semibold text-[#cdd9e5] mb-4">{editing ? 'Edit Category' : 'Add Category'}</h2>
            <form onSubmit={handleSubmit} className="space-y-3">
              {[['name','Name'],['icon','Icon (emoji)'],['description','Description']].map(([key,label]) => (
                <div key={key}>
                  <label className="block text-xs text-[#8b949e] mb-1">{label}</label>
                  <input value={form[key]} onChange={e => setForm({...form,[key]:e.target.value})}
                    className="w-full px-3 py-2 text-sm bg-[#0d1117] border border-[#2d333b] rounded-md text-[#cdd9e5] focus:outline-none focus:border-[#20c9c9]"
                    required={key === 'name'}/>
                </div>
              ))}
              <div className="flex gap-3 pt-2">
                <button type="button" onClick={() => setShowModal(false)} className="flex-1 py-2 text-sm border border-[#2d333b] rounded-md text-[#8b949e] hover:bg-[#21262d] transition-colors">Cancel</button>
                <button type="submit" className="flex-1 py-2 text-sm bg-[#20c9c9] bg-opacity-10 border border-[#20c9c9] border-opacity-30 text-[#20c9c9] rounded-md hover:bg-opacity-20 transition-colors">{editing ? 'Update' : 'Create'}</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
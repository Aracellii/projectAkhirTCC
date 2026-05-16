import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import './Login.css';

export default function Login() {
  const [formData, setFormData] = useState({ username: '', password: '' });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();
  const API_BASE_URL = 'http://localhost:5000/api/v1/users';

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.username || !formData.password) {
      setError('Username dan password harus diisi');
      return;
    }
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username: formData.username, password: formData.password })
      });
      if (!response.ok) {
        const data = await response.json();
        throw new Error(data.message || 'Login gagal');
      }
      const data = await response.json();
      localStorage.setItem('token', data.token);
      localStorage.setItem('username', formData.username);
      localStorage.setItem('roles', data.roles);
      
      if (data.roles !== 'admin') {
        setError('Hanya admin yang dapat mengakses dashboard. Hubungi administrator untuk naik level.');
        return;
      }
      
      navigate('/admin');
    } catch (err) {
      setError(err.message || 'Terjadi kesalahan');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-page">
      {/* Left panel */}
      <div className="login-left">
        <div className="login-left-content">
          <div className="login-logo">
            <div className="login-logo-icon">♻️</div>
            <span className="login-logo-text">Waste<span>Pro</span></span>
          </div>

          <div className="login-hero-text">
            <h2>Selamat<br />Datang <em>Kembali</em></h2>
            <p>Kelola lokasi donasi dan kategori produk daur ulang dari satu dashboard terpadu.</p>

            <div className="login-features">
              <div className="login-feature">
                <div className="login-feature-icon">📍</div>
                Manajemen Lokasi Donasi
              </div>
              <div className="login-feature">
                <div className="login-feature-icon">🗂️</div>
                Kategori Produk & Kredit
              </div>
              <div className="login-feature">
                <div className="login-feature-icon">🔒</div>
                Akses Aman & Terenkripsi
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Right panel */}
      <div className="login-right">
        <div className="login-form-container">
          <div className="login-form-header">
            <h1>Masuk ke Akun</h1>
            <p>Gunakan kredensial admin Anda untuk melanjutkan</p>
          </div>

          <form onSubmit={handleSubmit}>
            <div className="field">
              <label htmlFor="username">Username</label>
              <div className="field-input-wrap">
                <span className="field-icon">👤</span>
                <input
                  type="text"
                  id="username"
                  name="username"
                  value={formData.username}
                  onChange={handleChange}
                  placeholder="Masukkan username Anda"
                  required
                />
              </div>
            </div>

            <div className="field">
              <label htmlFor="password">Password</label>
              <div className="field-input-wrap">
                <span className="field-icon">🔑</span>
                <input
                  type="password"
                  id="password"
                  name="password"
                  value={formData.password}
                  onChange={handleChange}
                  placeholder="Masukkan password Anda"
                  required
                />
              </div>
            </div>

            {error && (
              <div className="form-error">
                <span className="form-error-icon">⚠️</span>
                {error}
              </div>
            )}

            <button type="submit" className="btn-submit" disabled={loading}>
              <span className="btn-submit-inner">
                {loading ? (
                  <>
                    <span className="btn-spinner" />
                    Sedang masuk...
                  </>
                ) : (
                  'Masuk ke Dashboard'
                )}
              </span>
            </button>
          </form>

          <p className="form-footer-link">
            Belum punya akun? <Link to="/register">Daftar sekarang</Link>
          </p>
        </div>
      </div>
    </div>
  );
}
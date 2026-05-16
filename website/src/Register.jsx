import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import './Register.css';

export default function Register() {
  const [formData, setFormData] = useState({
    username: '', email: '', password: '', confirmPassword: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const navigate = useNavigate();
  const API_BASE_URL = 'http://localhost:5000/api/v1/users';

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.username || !formData.email || !formData.password || !formData.confirmPassword) {
      setError('Semua field harus diisi');
      return;
    }
    if (formData.password !== formData.confirmPassword) {
      setError('Password tidak cocok');
      return;
    }
    if (formData.password.length < 6) {
      setError('Password minimal 6 karakter');
      return;
    }
    if (!formData.email.includes('@')) {
      setError('Email tidak valid');
      return;
    }

    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          username: formData.username,
          email: formData.email,
          password: formData.password
        })
      });
      if (!response.ok) {
        const data = await response.json();
        throw new Error(data.message || 'Registrasi gagal');
      }
      setSuccess('Akun berhasil dibuat! Mengarahkan ke halaman login...');
      setTimeout(() => navigate('/login'), 2000);
    } catch (err) {
      setError(err.message || 'Terjadi kesalahan');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="register-page">
      {/* Left panel */}
      <div className="register-left">
        <div className="register-left-content">
          <div className="register-logo">
            <div className="register-logo-icon">♻️</div>
            <span className="register-logo-text">Waste<span>Pro</span></span>
          </div>

          <div className="register-hero-text">
            <h2>Bergabung<br /><em>Bersama</em> Kami</h2>
            <p>Daftar sebagai admin dan mulai kelola ekosistem daur ulang komunitas Anda.</p>

            <div className="register-steps">
              <div className="register-step">
                <div className="register-step-num">1</div>
                <div className="register-step-text">Buat akun dengan email dan username Anda</div>
              </div>
              <div className="register-step">
                <div className="register-step-num">2</div>
                <div className="register-step-text">Login ke dashboard admin</div>
              </div>
              <div className="register-step">
                <div className="register-step-num">3</div>
                <div className="register-step-text">Kelola lokasi & kategori produk daur ulang</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Right panel */}
      <div className="register-right">
        <div className="register-form-container">
          <div className="register-form-header">
            <h1>Buat Akun Baru</h1>
            <p>Isi formulir di bawah untuk mendaftar sebagai admin</p>
          </div>

          <form onSubmit={handleSubmit}>
            <div className="field">
              <label htmlFor="username">Username</label>
              <div className="field-input-wrap">
                <span className="field-icon"></span>
                <input
                  type="text"
                  id="username"
                  name="username"
                  value={formData.username}
                  onChange={handleChange}
                  placeholder="Pilih username Anda"
                  required
                />
              </div>
            </div>

            <div className="field">
              <label htmlFor="email">Email</label>
              <div className="field-input-wrap">
                <span className="field-icon"></span>
                <input
                  type="email"
                  id="email"
                  name="email"
                  value={formData.email}
                  onChange={handleChange}
                  placeholder="nama@email.com"
                  required
                />
              </div>
            </div>

            <div className="field">
              <label htmlFor="password">Password</label>
              <div className="field-input-wrap">
                <span className="field-icon"></span>
                <input
                  type="password"
                  id="password"
                  name="password"
                  value={formData.password}
                  onChange={handleChange}
                  placeholder="Minimal 6 karakter"
                  required
                />
              </div>
              <p className="field-hint">Gunakan kombinasi huruf dan angka</p>
            </div>

            <div className="field">
              <label htmlFor="confirmPassword">Konfirmasi Password</label>
              <div className="field-input-wrap">
                <span className="field-icon"></span>
                <input
                  type="password"
                  id="confirmPassword"
                  name="confirmPassword"
                  value={formData.confirmPassword}
                  onChange={handleChange}
                  placeholder="Ulangi password Anda"
                  required
                />
              </div>
            </div>

            {error && (
              <div className="form-error">
                <span className="form-error-icon"></span>
                {error}
              </div>
            )}
            {success && (
              <div className="form-success">
                <span></span>
                {success}
              </div>
            )}

            <button type="submit" className="btn-submit" disabled={loading}>
              <span className="btn-submit-inner">
                {loading ? (
                  <>
                    <span className="btn-spinner" />
                    Membuat akun...
                  </>
                ) : (
                  'Buat Akun Sekarang'
                )}
              </span>
            </button>
          </form>

          <p className="form-footer-link">
            Sudah punya akun? <Link to="/login">Masuk di sini</Link>
          </p>
        </div>
      </div>
    </div>
  );
}
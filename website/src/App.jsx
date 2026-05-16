import { BrowserRouter, Routes, Route, Link, Navigate } from 'react-router-dom';
import AdminDashboard from './AdminDashboard';
import './App.css';
import Login from './Login';
import Register from './Register';

function Home() {
  return (
    <div className="home-page">
      {/* Nav */}
      <nav className="nav">
        <div className="nav-brand">
          <div className="nav-logo">♻️</div>
          <span className="nav-name">Waste<span>Pro</span></span>
        </div>
        <span className="nav-badge">Admin Portal</span>
      </nav>

      {/* Hero */}
      <section className="hero-section">
        <div className="hero-tag">
          <span className="hero-tag-dot" />
          Platform Aktif
        </div>

        <h1 className="hero-title">
          Kelola Sampah<br />
          Lebih <em>Cerdas</em>
        </h1>

        <p className="hero-subtitle">
          Sistem manajemen sampah terpadu untuk komunitas yang lebih bersih, 
          hijau, dan berkelanjutan.
        </p>

        <div className="hero-actions">
          <Link to="/login" className="btn-hero-primary">
            Masuk ke Dashboard →
          </Link>
          <Link to="/register" className="btn-hero-secondary">
            Buat Akun Baru
          </Link>
        </div>

        {/* Stats */}
        <div className="hero-stats">
          <div className="stat-item">
            <span className="stat-value">100%</span>
            <span className="stat-label">Berbasis Web</span>
          </div>
          <div className="stat-item">
            <span className="stat-value">Real-time</span>
            <span className="stat-label">Pembaruan Data</span>
          </div>
          <div className="stat-item">
            <span className="stat-value">Aman</span>
            <span className="stat-label">JWT Auth</span>
          </div>
        </div>
      </section>

      <footer className="home-footer">
        © 2025 WastePro · Sistem Manajemen Sampah
      </footer>
    </div>
  );
}

function ProtectedRoute({ element }) {
  const token = localStorage.getItem('token');
  const roles = localStorage.getItem('roles');
  
  if (!token) {
    return <Navigate to="/login" replace />;
  }
  
  if (roles !== 'admin') {
    return <Navigate to="/login" replace />;
  }
  
  return element;
}

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        <Route path="/admin" element={<ProtectedRoute element={<AdminDashboard />} />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
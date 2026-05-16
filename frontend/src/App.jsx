import { useEffect, useState } from "react";
import "./App.css";

const API_URL = import.meta.env.VITE_API_URL ?? "http://localhost:5000";

function App() {
  const [tickets, setTickets] = useState([]);
  const [activePage, setActivePage] = useState("dashboard");
  const [formData, setFormData] = useState({
    title: "",
    description: "",
    category: "Hardware",
    priority: "Medium",
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const fetchTickets = async () => {
    try {
      setError("");
      const response = await fetch(`${API_URL}/api/tickets`);

      if (!response.ok) {
        throw new Error("Unable to load tickets");
      }

      const data = await response.json();
      setTickets(data);
    } catch (err) {
      setError("Tickets could not be loaded. Database may not be running yet.");
    }
  };

  useEffect(() => {
    fetchTickets();
  }, []);

  const handleInputChange = (event) => {
    const { name, value } = event.target;

    setFormData({
      ...formData,
      [name]: value,
    });
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setLoading(true);
    setError("");

    try {
      const response = await fetch(`${API_URL}/api/tickets`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(formData),
      });

      if (!response.ok) {
        throw new Error("Unable to create ticket");
      }

      setFormData({
        title: "",
        description: "",
        category: "Hardware",
        priority: "Medium",
      });

      fetchTickets();
    } catch (err) {
      setError("Ticket could not be created. Check backend/database connection.");
    } finally {
      setLoading(false);
    }
  };

  const updateTicketStatus = async (ticketId, status) => {
    try {
      setError("");

      const response = await fetch(`${API_URL}/api/tickets/${ticketId}/status`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ status }),
      });

      if (!response.ok) {
        throw new Error("Unable to update ticket");
      }

      fetchTickets();
    } catch (err) {
      setError("Ticket status could not be updated.");
    }
  };

  const totalTickets = tickets.length;
  const openTickets = tickets.filter((ticket) => ticket.status === "Open").length;
  const inProgressTickets = tickets.filter(
    (ticket) => ticket.status === "In Progress"
  ).length;
  const resolvedTickets = tickets.filter(
    (ticket) => ticket.status === "Resolved"
  ).length;

  return (
    <div className="app">
      <aside className="sidebar">
        <h2>IT Support Portal</h2>
        <p>Incident Management</p>

        <nav>
          <button
            className={`nav-link ${activePage === "dashboard" ? "active" : ""}`}
            onClick={() => setActivePage("dashboard")}
          >
            Dashboard
          </button>

          <button
            className={`nav-link ${activePage === "tickets" ? "active" : ""}`}
            onClick={() => setActivePage("tickets")}
          >
            Tickets
          </button>

          <button
            className={`nav-link ${activePage === "reports" ? "active" : ""}`}
            onClick={() => setActivePage("reports")}
          >
            Reports
          </button>

          <button
            className={`nav-link ${activePage === "settings" ? "active" : ""}`}
            onClick={() => setActivePage("settings")}
          >
            Settings
          </button>
        </nav>
      </aside>

      <main className="main-content">
        <header className="page-header">
          <div>
            <h1>
              {activePage === "dashboard" && "Incident Dashboard"}
              {activePage === "tickets" && "Tickets"}
              {activePage === "reports" && "Reports"}
              {activePage === "settings" && "Settings"}
            </h1>

            <p>
              {activePage === "dashboard" &&
                "Monitor key IT support metrics and incident status."}
              {activePage === "tickets" &&
                "Create, view, and update internal IT support tickets."}
              {activePage === "reports" &&
                "View incident trends, summaries, and operational reports."}
              {activePage === "settings" &&
                "Manage application settings and notification preferences."}
            </p>
          </div>

          <span className="status-pill">Backend Connected</span>
        </header>

        {activePage === "dashboard" && (
          <>
            <section className="stats-grid">
              <div className="stat-card">
                <p>Total Tickets</p>
                <h3>{totalTickets}</h3>
              </div>

              <div className="stat-card">
                <p>Open</p>
                <h3>{openTickets}</h3>
              </div>

              <div className="stat-card">
                <p>In Progress</p>
                <h3>{inProgressTickets}</h3>
              </div>

              <div className="stat-card">
                <p>Resolved</p>
                <h3>{resolvedTickets}</h3>
              </div>
            </section>

            <section className="content-grid">
              <div className="panel">
                <h2>Dashboard Overview</h2>
                <p>
                  This dashboard gives a quick view of all support tickets,
                  including open, in progress, and resolved incidents.
                </p>
              </div>

              <div className="panel">
                <h2>System Status</h2>
                <p>
                  Backend API, PostgreSQL database, and frontend services are
                  running through Docker Compose.
                </p>
              </div>
            </section>
          </>
        )}

        {activePage === "tickets" && (
          <section className="content-grid">
            <div className="panel">
              <h2>Create New Incident</h2>

              <form onSubmit={handleSubmit} className="ticket-form">
                <label>
                  Title
                  <input
                    type="text"
                    name="title"
                    value={formData.title}
                    onChange={handleInputChange}
                    placeholder="Example: Laptop not powering on"
                    required
                  />
                </label>

                <label>
                  Description
                  <textarea
                    name="description"
                    value={formData.description}
                    onChange={handleInputChange}
                    placeholder="Describe the issue..."
                    required
                  />
                </label>

                <label>
                  Category
                  <select
                    name="category"
                    value={formData.category}
                    onChange={handleInputChange}
                  >
                    <option>Hardware</option>
                    <option>Software</option>
                    <option>Network</option>
                    <option>Access</option>
                    <option>Other</option>
                  </select>
                </label>

                <label>
                  Priority
                  <select
                    name="priority"
                    value={formData.priority}
                    onChange={handleInputChange}
                  >
                    <option>Low</option>
                    <option>Medium</option>
                    <option>High</option>
                    <option>Critical</option>
                  </select>
                </label>

                <button type="submit" disabled={loading}>
                  {loading ? "Creating..." : "Create Ticket"}
                </button>
              </form>

              {error && <p className="error-message">{error}</p>}
            </div>

            <div className="panel tickets-panel">
              <h2>Recent Tickets</h2>

              {tickets.length === 0 ? (
                <p className="empty-state">
                  No tickets found yet. Create your first incident ticket.
                </p>
              ) : (
                <div className="tickets-list">
                  {tickets.map((ticket) => (
                    <div key={ticket.id} className="ticket-card">
                      <div className="ticket-header">
                        <div>
                          <h3>{ticket.title}</h3>
                          <p>{ticket.description}</p>
                        </div>

                        <span
                          className={`priority ${ticket.priority.toLowerCase()}`}
                        >
                          {ticket.priority}
                        </span>
                      </div>

                      <div className="ticket-meta">
                        <span>{ticket.category}</span>

                        <select
                          value={ticket.status}
                          onChange={(event) =>
                            updateTicketStatus(ticket.id, event.target.value)
                          }
                        >
                          <option>Open</option>
                          <option>In Progress</option>
                          <option>Resolved</option>
                        </select>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </section>
        )}

        {activePage === "reports" && (
          <section className="content-grid">
            <div className="panel">
              <h2>Incident Reports</h2>
              <p>
                This section will show ticket trends, priority breakdowns,
                response times, and monthly incident summaries.
              </p>
            </div>

            <div className="panel">
              <h2>Current Summary</h2>
              <p>Total Tickets: {totalTickets}</p>
              <p>Open Tickets: {openTickets}</p>
              <p>In Progress: {inProgressTickets}</p>
              <p>Resolved Tickets: {resolvedTickets}</p>
            </div>
          </section>
        )}

        {activePage === "settings" && (
          <section className="content-grid">
            <div className="panel">
              <h2>Application Settings</h2>
              <p>
                This section will later include notification settings, user
                preferences, and admin configuration.
              </p>
            </div>

            <div className="panel">
              <h2>Monitoring Setup</h2>
              <p>
                Prometheus, Grafana, cAdvisor, Alertmanager, Mailpit, and k6
                are connected as part of the monitoring stage.
              </p>
            </div>
          </section>
        )}
      </main>
    </div>
  );
}

export default App;

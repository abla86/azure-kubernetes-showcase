import { useEffect, useState } from "react";
import "./App.css";

type Health = {
  status: string;
  service: string;
  timestamp: string;
};

type Info = {
  application: string;
  version: string;
  runtime: string;
  environment: string;
};

type EventItem = {
  type: string;
  message: string;
  timestamp: string;
};

function App() {
  const [health, setHealth] = useState<Health | null>(null);
  const [info, setInfo] = useState<Info | null>(null);
  const [events, setEvents] = useState<EventItem[]>([]);
  const [error, setError] = useState("");

  useEffect(() => {
    const load = async () => {
      try {
        const [healthResponse, infoResponse, eventsResponse] = await Promise.all([
          fetch("/api/health"),
          fetch("/api/info"),
          fetch("/api/events")
        ]);

        if (!healthResponse.ok || !infoResponse.ok || !eventsResponse.ok) {
          throw new Error("API request failed");
        }

        setHealth(await healthResponse.json());
        setInfo(await infoResponse.json());
        setEvents(await eventsResponse.json());
        setError("");
      } catch {
        setError(
          "API er ikke tilgjengelig. Start ASP.NET Core API-et for lokal kjøring."
        );
      }
    };

    load();
  }, []);

  return (
    <main className="dashboard">
      <header className="hero">
        <div>
          <p className="eyebrow">CLOUD ENGINEERING PORTFOLIO</p>
          <h1>Azure Kubernetes Showcase</h1>
          <p className="subtitle">
            .NET · React · Docker · Kubernetes · Azure · IaC · CI/CD ·
            DevSecOps · Observability
          </p>
        </div>

        <div className={`status ${health ? "online" : "offline"}`}>
          <span />
          {health ? "API ONLINE" : "API OFFLINE"}
        </div>
      </header>

      {error && <section className="alert">{error}</section>}

      <section className="grid">
        <article className="card">
          <span className="label">SERVICE HEALTH</span>
          <strong>{health?.status ?? "—"}</strong>
          <small>{health?.service ?? "Waiting for API"}</small>
        </article>

        <article className="card">
          <span className="label">RUNTIME</span>
          <strong>{info?.runtime ?? "—"}</strong>
          <small>{info?.environment ?? "—"}</small>
        </article>

        <article className="card">
          <span className="label">VERSION</span>
          <strong>{info?.version ?? "—"}</strong>
          <small>{info?.application ?? "—"}</small>
        </article>

        <article className="card">
          <span className="label">PLATFORM</span>
          <strong>Cloud Ready</strong>
          <small>Container + Kubernetes</small>
        </article>
      </section>

      <section className="architecture">
        <h2>Engineering pipeline</h2>
        <div className="pipeline">
          {["React / TypeScript", "ASP.NET Core", "Docker", "Kubernetes", "Azure", "Observability"].map((item) => (
            <div className="pipelineItem" key={item}>
              {item}
            </div>
          ))}
        </div>
      </section>

      <section className="events">
        <h2>System events</h2>
        {events.length === 0 ? (
          <p className="muted">No events available.</p>
        ) : (
          events.map((event) => (
            <div className="event" key={`${event.type}-${event.timestamp}`}>
              <div>
                <strong>{event.type}</strong>
                <span>{event.message}</span>
              </div>
              <time>{new Date(event.timestamp).toLocaleString()}</time>
            </div>
          ))
        )}
      </section>
    </main>
  );
}

export default App;

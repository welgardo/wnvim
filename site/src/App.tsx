import Hero from "./components/Hero";
import ThemeGallery from "./components/ThemeGallery";
import FeatureNotes from "./components/FeatureNotes";
import Philosophy from "./components/Philosophy";
import Installation from "./components/Installation";
import GitHubSection from "./components/GitHubSection";
import Footer from "./components/Footer";

export default function App() {
  return (
    <div id="top" className="min-h-screen">
      <div className="grain" aria-hidden="true" />
      <Hero />
      <main>
        <ThemeGallery />
        <FeatureNotes />
        <Philosophy />
        <Installation />
        <GitHubSection />
      </main>
      <Footer />
    </div>
  );
}

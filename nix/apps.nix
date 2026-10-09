# Static metadata for each ArtCraft Crafting App. Versions and hashes live in ../sources.json
# (machine-written by `nix run .#update`); everything here is hand-maintained.
{
  photocraft = {
    displayName = "PhotoCraft";
    description = "Open-source, clean-room reimplementation of Adobe Photoshop in pure Rust";
    features = [ "heif" ];
  };
  lightcraft = {
    displayName = "LightCraft";
    description = "Open-source, clean-room reimplementation of Adobe Lightroom in pure Rust";
  };
  filmcraft = {
    displayName = "FilmCraft";
    description = "Open-source, clean-room reimplementation of Adobe Premiere Pro in pure Rust";
    audio = true;
  };
  pdfcraft = {
    displayName = "PDFCraft";
    description = "Open-source, clean-room reimplementation of Adobe Acrobat in pure Rust";
  };
  vectorcraft = {
    displayName = "VectorCraft";
    description = "Open-source, clean-room reimplementation of Adobe Illustrator in pure Rust";
  };
  effectcraft = {
    displayName = "EffectCraft";
    description = "Open-source motion graphics and visual effects app in pure Rust";
    audio = true;
  };
  designcraft = {
    displayName = "DesignCraft";
    description = "Open-source design app in pure Rust";
  };
  wordcraft = {
    displayName = "WordCraft";
    description = "Open-source, clean-room reimplementation of Microsoft Word in pure Rust";
  };
  cadcraft = {
    displayName = "CADCraft";
    description = "Open-source, clean-room AutoCAD-style CAD and drafting app in pure Rust";
  };
  gridcraft = {
    displayName = "GridCraft";
    description = "Open-source, clean-room Microsoft Excel-style spreadsheet in pure Rust";
  };
  deckcraft = {
    displayName = "DeckCraft";
    description = "Open-source, clean-room reimplementation of Microsoft PowerPoint in pure Rust";
    audio = true;
  };
  soundcraft = {
    displayName = "SoundCraft";
    description = "Open-source, clean-room reimplementation of Avid Pro Tools in pure Rust";
    audio = true;
  };
}

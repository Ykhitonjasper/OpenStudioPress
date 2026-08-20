import Foundation

struct StudioSeedData {
    static func blocks() -> [Block] {
        [
            Block(id: "blk-001", kind: .coverMark, heading: "Clay & Ash", body: "A quiet route through fired forms and charcoal studies.", order: 0, emphasis: true),
            Block(id: "blk-002", kind: .artistNote, heading: "Welcome", body: "Move slowly and begin with the work nearest the north window.", order: 1, emphasis: false),
            Block(id: "blk-003", kind: .exhibitStop, heading: "Kiln Shelf", body: "Notice how pale glaze gathers around each rim.", order: 2, emphasis: false),
            Block(id: "blk-004", kind: .processWindow, heading: "From Slip to Fire", body: "Each piece rests twice before its final firing.", order: 3, emphasis: false),
            Block(id: "blk-005", kind: .materialCallout, heading: "Stoneware", body: "Local stoneware, ash glaze, and iron oxide shape this group.", order: 4, emphasis: false),
            Block(id: "blk-006", kind: .lookingPrompt, heading: "Follow the Edge", body: "Where does the silhouette become most delicate?", order: 5, emphasis: true),
            Block(id: "blk-007", kind: .studioEtiquette, heading: "Around the Plinth", body: "Please leave a clear path around the low display.", order: 6, emphasis: false),
            Block(id: "blk-008", kind: .takeHomeNote, heading: "Carry This Detail", body: "Remember one surface that changed as you moved.", order: 7, emphasis: false),
            Block(id: "blk-009", kind: .coverMark, heading: "Four Drawings Slowly", body: "A measured visit to graphite, paper, and repeated lines.", order: 0, emphasis: true),
            Block(id: "blk-010", kind: .artistNote, heading: "Reading the Series", body: "The drawings reward distance first and close looking second.", order: 1, emphasis: false),
            Block(id: "blk-011", kind: .exhibitStop, heading: "First Drawing", body: "Begin with the broad diagonal crossing the upper field.", order: 2, emphasis: false),
            Block(id: "blk-012", kind: .lookingPrompt, heading: "Find the Pause", body: "Which unmarked space holds the longest pause?", order: 3, emphasis: true),
            Block(id: "blk-013", kind: .processWindow, heading: "Layered Graphite", body: "Soft grades establish haze before hard lines arrive.", order: 4, emphasis: false),
            Block(id: "blk-014", kind: .materialCallout, heading: "Paper Tooth", body: "A warm cotton sheet keeps each erased trace visible.", order: 5, emphasis: false),
            Block(id: "blk-015", kind: .studioEtiquette, heading: "Viewing Distance", body: "Step back to the floor mark before approaching details.", order: 6, emphasis: false),
            Block(id: "blk-016", kind: .takeHomeNote, heading: "One Remembered Line", body: "Sketch the line you can still picture after leaving.", order: 7, emphasis: false),
            Block(id: "blk-017", kind: .coverMark, heading: "The Blue Table Walk", body: "Objects, pigments, and working notes arranged in sequence.", order: 0, emphasis: true),
            Block(id: "blk-018", kind: .artistNote, heading: "Table as Map", body: "Read the tabletop from the doorway toward the window.", order: 1, emphasis: false),
            Block(id: "blk-019", kind: .exhibitStop, heading: "Cobalt Corner", body: "Compare the ceramic chip with the painted paper beside it.", order: 2, emphasis: false),
            Block(id: "blk-020", kind: .processWindow, heading: "Mixing Notes", body: "Small swatches record shifts in water and pigment.", order: 3, emphasis: false),
            Block(id: "blk-021", kind: .materialCallout, heading: "Blue Sources", body: "Cobalt, ultramarine, and indigo form three distinct temperatures.", order: 4, emphasis: false),
            Block(id: "blk-022", kind: .lookingPrompt, heading: "Warmest Blue", body: "Which sample feels warmest, and what sits beside it?", order: 5, emphasis: true),
            Block(id: "blk-023", kind: .studioEtiquette, heading: "Working Table", body: "View the marked objects without moving their arrangement.", order: 6, emphasis: false),
            Block(id: "blk-024", kind: .takeHomeNote, heading: "Color Memory", body: "Name the blue you would use for evening light.", order: 7, emphasis: false),
            Block(id: "blk-025", kind: .coverMark, heading: "Threadline Studio Notes", body: "A tactile route through woven samples and suspended studies.", order: 0, emphasis: true),
            Block(id: "blk-026", kind: .artistNote, heading: "Begin at the Loom", body: "The route follows a thread from structure to finished cloth.", order: 1, emphasis: false),
            Block(id: "blk-027", kind: .exhibitStop, heading: "Warp Study", body: "Look for the narrow red interruption near the center.", order: 2, emphasis: false),
            Block(id: "blk-028", kind: .processWindow, heading: "Tension Test", body: "Pinned samples show how spacing changes the final drape.", order: 3, emphasis: false),
            Block(id: "blk-029", kind: .materialCallout, heading: "Fiber Notes", body: "Linen, wool, and paper yarn create contrasting edges.", order: 4, emphasis: false),
            Block(id: "blk-030", kind: .lookingPrompt, heading: "Trace a Thread", body: "Follow one thread until it disappears from view.", order: 5, emphasis: true),
            Block(id: "blk-031", kind: .studioEtiquette, heading: "Textile Display", body: "Use the sample rail for pieces marked for touch.", order: 6, emphasis: false),
            Block(id: "blk-032", kind: .takeHomeNote, heading: "Texture Pair", body: "Remember two textures that changed each other.", order: 7, emphasis: false),
            Block(id: "blk-033", kind: .coverMark, heading: "Small Editions Saturday", body: "Prints, folded matter, and compact editions for a short visit.", order: 0, emphasis: true),
            Block(id: "blk-034", kind: .artistNote, heading: "Edition Table", body: "Start with the smallest format and move outward.", order: 1, emphasis: false),
            Block(id: "blk-035", kind: .exhibitStop, heading: "Two-Color Print", body: "Inspect the slight offset where the colors meet.", order: 2, emphasis: false),
            Block(id: "blk-036", kind: .processWindow, heading: "Registration", body: "Corner marks align each pass through the press.", order: 3, emphasis: false),
            Block(id: "blk-037", kind: .materialCallout, heading: "Ink and Stock", body: "Soy ink sits differently on coated and uncoated sheets.", order: 4, emphasis: false),
            Block(id: "blk-038", kind: .lookingPrompt, heading: "Spot the Shift", body: "Where does a small offset make the image feel active?", order: 5, emphasis: true),
            Block(id: "blk-039", kind: .studioEtiquette, heading: "Browse Gently", body: "Use the clean sample copy when turning pages.", order: 6, emphasis: false),
            Block(id: "blk-040", kind: .takeHomeNote, heading: "Fold to Remember", body: "Choose one fold that changed how the work unfolded.", order: 7, emphasis: false)
        ]
    }

    static func blockKinds() -> [BlockKindDescriptor] {
        [
            BlockKindDescriptor(id: "kind-cover", kind: .coverMark, label: "Cover Mark", guidance: "Open with title and visitor orientation."),
            BlockKindDescriptor(id: "kind-artist", kind: .artistNote, label: "Artist Note", guidance: "Frame the visit in the artist's voice."),
            BlockKindDescriptor(id: "kind-stop", kind: .exhibitStop, label: "Exhibit Stop", guidance: "Anchor attention to one work or grouping."),
            BlockKindDescriptor(id: "kind-process", kind: .processWindow, label: "Process Window", guidance: "Reveal one making decision or sequence."),
            BlockKindDescriptor(id: "kind-material", kind: .materialCallout, label: "Material Callout", guidance: "Name materials and their visual effect."),
            BlockKindDescriptor(id: "kind-looking", kind: .lookingPrompt, label: "Looking Prompt", guidance: "Invite a specific act of observation."),
            BlockKindDescriptor(id: "kind-etiquette", kind: .studioEtiquette, label: "Studio Etiquette", guidance: "Clarify movement and handling expectations."),
            BlockKindDescriptor(id: "kind-takehome", kind: .takeHomeNote, label: "Take-Home Note", guidance: "Close with a memorable reflection.")
        ]
    }

    static func templates() -> [Template] {
        [
            Template(id: "tpl-001", title: "First Open Studio", summary: "A balanced first-time visitor route.", size: .halfLetter, density: .balanced, blockIDs: ["blk-001", "blk-002", "blk-003", "blk-006", "blk-008"]),
            Template(id: "tpl-002", title: "Ceramic Shelf Walk", summary: "A shelf-by-shelf path through fired work.", size: .pocket, density: .airy, blockIDs: ["blk-001", "blk-003", "blk-004", "blk-005", "blk-006"]),
            Template(id: "tpl-003", title: "Small Print Release", summary: "A concise guide for a new edition.", size: .pocket, density: .balanced, blockIDs: ["blk-033", "blk-035", "blk-036", "blk-037", "blk-040"]),
            Template(id: "tpl-004", title: "Illustration Desk Tour", summary: "A route through sketches and final drawings.", size: .square, density: .detailed, blockIDs: ["blk-009", "blk-010", "blk-011", "blk-012", "blk-013"]),
            Template(id: "tpl-005", title: "Textile Wall Notes", summary: "Prompts for woven works displayed vertically.", size: .halfLetter, density: .balanced, blockIDs: ["blk-025", "blk-027", "blk-029", "blk-030", "blk-032"]),
            Template(id: "tpl-006", title: "Shared Atelier Saturday", summary: "A welcoming route across several work areas.", size: .halfLetter, density: .detailed, blockIDs: ["blk-002", "blk-007", "blk-018", "blk-026", "blk-034"]),
            Template(id: "tpl-007", title: "Mini Retrospective", summary: "A chronological sequence for a compact survey.", size: .square, density: .detailed, blockIDs: ["blk-010", "blk-011", "blk-013", "blk-015", "blk-016"]),
            Template(id: "tpl-008", title: "Sketchbook Cabinet", summary: "A close-looking guide for working books.", size: .pocket, density: .airy, blockIDs: ["blk-009", "blk-012", "blk-014", "blk-015", "blk-016"]),
            Template(id: "tpl-009", title: "Process Table", summary: "Materials and process arranged as a working map.", size: .square, density: .balanced, blockIDs: ["blk-017", "blk-019", "blk-020", "blk-021", "blk-023"]),
            Template(id: "tpl-010", title: "Three-Room Trail", summary: "Orientation and stops for a longer studio route.", size: .halfLetter, density: .detailed, blockIDs: ["blk-002", "blk-003", "blk-019", "blk-027", "blk-040"]),
            Template(id: "tpl-011", title: "Night Gallery Guide", summary: "A spacious guide for an evening viewing.", size: .square, density: .airy, blockIDs: ["blk-001", "blk-006", "blk-017", "blk-022", "blk-024"]),
            Template(id: "tpl-012", title: "Student Portfolio Walk", summary: "Clear prompts for viewing a developing practice.", size: .halfLetter, density: .balanced, blockIDs: ["blk-009", "blk-010", "blk-012", "blk-013", "blk-016"]),
            Template(id: "tpl-013", title: "Makers’ Courtyard", summary: "A movement-friendly route around shared displays.", size: .pocket, density: .airy, blockIDs: ["blk-002", "blk-007", "blk-023", "blk-031", "blk-040"]),
            Template(id: "tpl-014", title: "Color Study Route", summary: "A prompt-led walk through color relationships.", size: .square, density: .balanced, blockIDs: ["blk-017", "blk-019", "blk-021", "blk-022", "blk-024"]),
            Template(id: "tpl-015", title: "Closing-Day Guide", summary: "A reflective final-day booklet with takeaways.", size: .halfLetter, density: .detailed, blockIDs: ["blk-025", "blk-028", "blk-030", "blk-032", "blk-040"])
        ]
    }

    static func artifacts() -> [Artifact] {
        let date = Date(timeIntervalSince1970: 1_750_000_000)
        return [
            Artifact(id: "art-001", title: "Clay & Ash", size: .halfLetter, density: .balanced, foldRhythm: .paired, blockIDs: Array((1...8).map { String(format: "blk-%03d", $0) }), createdAt: date),
            Artifact(id: "art-002", title: "Four Drawings Slowly", size: .square, density: .airy, foldRhythm: .single, blockIDs: Array((9...16).map { String(format: "blk-%03d", $0) }), createdAt: date.addingTimeInterval(60)),
            Artifact(id: "art-003", title: "The Blue Table Walk", size: .pocket, density: .balanced, foldRhythm: .alternating, blockIDs: Array((17...24).map { String(format: "blk-%03d", $0) }), createdAt: date.addingTimeInterval(120)),
            Artifact(id: "art-004", title: "Threadline Studio Notes", size: .halfLetter, density: .detailed, foldRhythm: .paired, blockIDs: Array((25...32).map { String(format: "blk-%03d", $0) }), createdAt: date.addingTimeInterval(180)),
            Artifact(id: "art-005", title: "Small Editions Saturday", size: .pocket, density: .balanced, foldRhythm: .single, blockIDs: Array((33...40).map { String(format: "blk-%03d", $0) }), createdAt: date.addingTimeInterval(240))
        ]
    }
}

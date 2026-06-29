# Static Website - GitHub Pages

This directory contains **static HTML/CSS files** for the pbuild-ai-examples website.

## Files

- `index.html` - Main landing page (static)
- `benchmark-report.html` - Benchmark results (generated, static)
- `style.css` - Styling (pure CSS, no preprocessing)
- `CNAME` - Custom domain configuration (optional)

## Fully Static

✅ **No server-side processing required**
✅ **No JavaScript framework needed**
✅ **No build step needed**
✅ **Pure HTML/CSS**

GitHub Pages serves these files directly as-is.

## Viewing Locally

### Option 1: Direct File Access
Simply open `index.html` in your browser:

```bash
# macOS
open index.html

# Linux
xdg-open index.html

# Windows
start index.html
```

### Option 2: Local Web Server (Optional)
For testing relative links:

```bash
python3 -m http.server 8000
# Visit: http://localhost:8000
```

The server is **only for local testing**. GitHub Pages hosts the static files without it.

## GitHub Pages Deployment

The files are served as static content by GitHub Pages:

1. **Push to GitHub**
   ```bash
   git push origin main
   ```

2. **GitHub Actions workflow** (`../.github/workflows/update-website.yml`) automatically deploys

3. **GitHub Pages** serves the static files at:
   ```
   https://USERNAME.github.io/pbuild-ai-examples/
   ```

No build process, no server - just static file hosting!

## Updating the Website

### Update Landing Page
Edit `index.html` directly - it's static HTML.

### Update Benchmark Report
Run the generator script (creates static HTML):
```bash
cd ..
./scripts/generate-report.sh
```

This reads JSON files and generates static `benchmark-report.html`.

### Update Styles
Edit `style.css` directly - it's pure CSS, no preprocessing.

## Custom Domain (Optional)

To use a custom domain:

1. Add your domain to `CNAME` file
2. Configure DNS to point to GitHub Pages
3. Enable in GitHub repository settings

## Technology Stack

- **HTML5** - Semantic markup
- **CSS3** - Modern styling with variables
- **SVG** - Scalable icons
- **No JavaScript** - Pure static content
- **No build tools** - Direct file editing

Perfect for GitHub Pages static hosting!

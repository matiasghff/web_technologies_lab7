cat > README.md <<'EOF'
# VetClinic — Lab 7

VetClinic is a Ruby on Rails application for managing owners, pets, veterinarians, appointments, and treatments.

Lab 7 adds:

- Active Storage for pet profile photos.
- Action Text for rich clinical notes on treatments.
- Image thumbnails in the Pets index.
- Rich-text treatment notes using the Trix editor.

## Requirements

- Ruby 4.0.1
- Rails 8.1.3
- PostgreSQL
- Yarn
- libvips for Active Storage image variants

## System dependency: libvips

Active Storage variants are used to generate resized pet thumbnails. Rails uses libvips for image processing, so it must be installed locally.

On macOS with Homebrew:

<pre><code>brew install vips</code></pre>

You can verify the installation with:

<pre><code>vips --version</code></pre>

## Setup

Install dependencies:

<pre><code>bundle install
yarn install</code></pre>

Create and set up the database:

<pre><code>bin/rails db:setup</code></pre>

To reset everything from scratch:

<pre><code>bin/rails db:drop db:create db:migrate db:seed</code></pre>

## Run the app

Start the development server:

<pre><code>bin/dev</code></pre>

Then open:

<pre><code>http://localhost:3000</code></pre>

## Run tests and lint

Run the test suite:

<pre><code>bin/rails test</code></pre>

Run RuboCop:

<pre><code>bin/rubocop</code></pre>

Auto-correct style issues when possible:

<pre><code>bin/rubocop -A</code></pre>

## Active Storage

Pets can have one optional attached profile photo.

The app validates that attached photos are:

- JPEG, PNG, or WebP.
- 5 MB or smaller.

Pet photos are displayed:

- As a full image or placeholder on the pet show page.
- As 60x60 thumbnails on the pets index page using Active Storage variants.

Sample pet photos are stored under:

<pre><code>db/seeds/pets/</code></pre>

and attached through `db/seeds.rb`.

## Action Text

Treatments use Action Text for rich clinical notes through the `clinical_notes` attribute.

The treatment form uses the Trix editor, allowing formatted content such as:

- Headings
- Bold and italic text
- Lists
- Links

The appointment show page renders the rich clinical notes directly and eager-loads them with `with_rich_text_clinical_notes` to avoid N+1 queries.

## Sanitization check

I manually tested Action Text sanitization by pasting the following into the Trix editor for a treatment:

<pre><code>&lt;script&gt;alert(1)&lt;/script&gt;
&lt;h3&gt;Sanitization test&lt;/h3&gt;
&lt;p&gt;This text should remain visible.&lt;/p&gt;</code></pre>

After saving, no alert was executed. The script content appeared as escaped text instead of running as JavaScript, confirming that the dangerous HTML was not executed.
EOF
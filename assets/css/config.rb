# Require any additional compass plugins here.

# Set this to the root of your project when deployed:
http_path = "/"

sass_dir = "."
css_dir = "."
images_dir = "../images/"
generated_images_dir = "../images"
# sprite_load_path = generated_images_dir
javascripts_dir = "../js"

# You can select your preferred output style here (can be overridden via the command line):
# output_style = :expanded or :nested or :compact or :compressed
output_style = :nested
# environment = :developpement

# To enable relative paths to assets via compass helper functions. Uncomment:
relative_assets = true

# To disable debugging comments that display the original location of your selectors. Uncomment:
line_comments = true

sass_options = { :debug_info => true }


# If you prefer the indented syntax, you might want to regenerate this
# project again passing --syntax sass, or you can uncomment this:
# preferred_syntax = :sass
# and then run:
# sass-convert -R --from scss --to sass sass scss && rm -rf sass && mv scss sass
use glow::HasContext;
use image::{ImageBuffer, Rgba};
use std::fs::File;
use std::io::BufWriter;

fn main() {
    // Initialize the OpenGL context with EGL (supports off-screen on macOS)
    let (gl, _egl_context) = unsafe {
        let egl_display =
            egl::get_display(egl::EGL_DEFAULT_DISPLAY).expect("Failed to get EGL display");
        let mut major = 0;
        let mut minor = 0;
        let result = egl::initialize(egl_display, &mut major, &mut minor);
        println!("egl::initialize: {result}");

        let config = egl::choose_config(
            egl_display,
            &[
                egl::EGL_RED_SIZE,
                8,
                egl::EGL_GREEN_SIZE,
                8,
                egl::EGL_BLUE_SIZE,
                8,
                egl::EGL_NONE,
            ],
            1,
        )
        .expect("Failed to choose EGL config");
        let egl_context = egl::create_context(
            egl_display,
            config,
            egl::EGL_NO_CONTEXT,
            &[egl::EGL_CONTEXT_CLIENT_VERSION, 2, egl::EGL_NONE],
        )
        .expect("Failed to create EGL context");

        let egl_surface = egl::create_pbuffer_surface(
            egl_display,
            config,
            &[egl::EGL_WIDTH, 256, egl::EGL_HEIGHT, 256, egl::EGL_NONE],
        )
        .expect("Failed to create EGL pbuffer surface");

        let result = egl::make_current(egl_display, egl_surface, egl_surface, egl_context);
        println!("egl::make_current = {result}");

        let gl = glow::Context::from_loader_function(|s| egl::get_proc_address(s) as *const _);
        (gl, egl_context)
    };

    // Set up OpenGL framebuffer and buffer size.
    let width = 256;
    let height = 256;

    unsafe {
        gl.clear_color(0.2, 0.3, 0.3, 1.0);
        gl.clear(glow::COLOR_BUFFER_BIT);
    }

    // Read pixels from the framebuffer into a buffer.
    let mut pixels = vec![0u8; (width * height * 4) as usize];
    unsafe {
        gl.read_pixels(
            0,
            0,
            width as i32,
            height as i32,
            glow::RGBA,
            glow::UNSIGNED_BYTE,
            glow::PixelPackData::Slice(&mut pixels),
        );
    }

    // Convert buffer into an image and save it as a PNG.
    let buffer: ImageBuffer<Rgba<u8>, _> =
        ImageBuffer::from_raw(width, height, pixels).expect("Failed to create image buffer");
    let file = File::create("output.png").expect("Failed to create output file");
    let mut writer = BufWriter::new(file);
    buffer
        .write_to(&mut writer, image::ImageFormat::Png)
        .expect("Failed to write PNG");
}

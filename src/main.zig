const std = @import("std");
const zgl = @import("zgl");
const glfw = @import("glfw");

pub fn main() !void {

    // We need initializing glfw
    try glfw.init(.{});
    defer glfw.terminate();

    // Create our window
    const window = try glfw.Window.create(640, 480, "Triangle", null, null, .{
        .context_version_major = 3,
        .context_version_minor = 3,
        .opengl_profile = .opengl_core_profile
    });
    defer window.destroy();
    
    try glfw.makeContextCurrent(window);

    // Load OpenGL functions
    try zgl.loadExtensions(0, struct {
        pub fn getProc(comptime _: comptime_int, name: [:0]const u8) ?*const anyopaque {
            return glfw.getProcAddress(name);
        }
    }.getProc);

    // Create vertex shader and compile it from the source file
    const v_shader = zgl.Shader.create(.vertex);
    defer v_shader.delete();
    v_shader.source(1, &[_][]const u8{@embedFile("shader.vert")});
    v_shader.compile();

    // Create fragment shader and compile it from the source file
    const f_shader = zgl.Shader.create(.fragment);
    defer f_shader.delete();
    f_shader.source(1, &[_][]const u8{@embedFile("shader.frag")});
    f_shader.compile();
    
    // Create program to attach both shaders
    const program = zgl.Program.create();
    defer program.delete();
    program.attach(v_shader);
    program.attach(f_shader);
    program.link();

    // Triangle vertices
    const vertices = [_] f32 {
        -0.5, -0.5, 0.0, // left  
         0.5, -0.5, 0.0, // right 
         0.0,  0.5, 0.0  // top   
    };

    // Create buffer and submit the data
    const vbo = zgl.Buffer.gen();
    defer vbo.delete();

    zgl.bindBuffer(vbo, .array_buffer);
    zgl.bufferData(.array_buffer, f32, &vertices, .static_draw);

    // We create a vao so we can save the attrib or vbo actions
    const vao = zgl.VertexArray.gen();
    defer vao.delete();
    vao.bind();

    // Now we create a vao so we can record the attribs here
    zgl.vertexAttribPointer(0, 3, .float, false, 0, 0);
    zgl.enableVertexAttribArray(0);
    
    zgl.bindVertexArray(@intToEnum(zgl.VertexArray, 0));

    // Now we prepare everything, we going to render the triangle
    program.use();
    vao.bind();

    // Wait for the user to close the window.
    while (!window.shouldClose()) {
        zgl.clearColor(0, 0, 0, 1);
        zgl.clear(.{
            .color = true,
            //.depth = true
        });

        // We draw the triangle here
        zgl.drawArrays(.triangles, 0, 3);
        
        try window.swapBuffers();
        try glfw.pollEvents();
    }

}


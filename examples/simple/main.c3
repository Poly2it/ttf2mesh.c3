/*
 * Copyright 2024 polybit
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


module simple;
import rl;
import ttf;
import ttf::c3;
import std::io;


fault GlyphGenerationResult {
    GLYPH_GENERATION_FAILED
}


fn int main() {
    ttf::Mesh* ttf_mesh = {|
        ttf::File** font_matches = ttf::c3::font_find_by_match("DejaVuSans*|Ubuntu*|FreeSerif*|Arial*|Cour*")!!;
        defer ttf::free_list(font_matches);
        ttf::File* font = ttf::c3::font_load_by_filename(font_matches[0].filename)!!;
        defer ttf::free(font);
    
        io::printf("INFO: Font \"%s\" loaded\n", font.names.full_name);
    
        CInt index = font.find_glyph_index('⅛')!!;

        ttf::Mesh* ttf_mesh_intermediate = mem::new(ttf::Mesh);
        if (
            ttf::glyph2mesh(
                &font.glyphs[index], 
                &ttf_mesh_intermediate, 
                ttf::QUALITY_HIGH, 
                ttf::FEATURES_DFLT
            ) != ttf::DONE
        ) {
            return GlyphGenerationResult.GLYPH_GENERATION_FAILED?;
        }

        return ttf_mesh_intermediate;
    |}!!;
    defer ttf::free_mesh(ttf_mesh);

    io::printf("INFO: Created glyph mesh\n");

    const int WINDOW_WIDTH = 800;
    const int WINDOW_HEIGHT = 450;

    rl::setConfigFlags(
        rl::config::MSAA_4X_HINT |
        rl::config::VSYNC_HINT |
        rl::config::WINDOW_RESIZABLE
    );
    rl::initWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "ttf2mesh simple example");
    defer rl::closeWindow();

    rl::Texture2D texture = {|
        rl::Image checked = rl::genImageColor(1, 1, rl::BLACK);
        defer rl::unloadImage(checked);

        return rl::loadTextureFromImage(checked);
    |};
    defer rl::unloadTexture(texture);

    rl::Model model = rl::loadModelFromMesh(gen_mesh_from_ttf_mesh(ttf_mesh));
    defer rl::unloadModel(model);

    model.materials[0].maps[rl::MaterialMapIndex.ALBEDO].texture = texture;
    model.transform.multiply(model.transform.rotateX(-45.0f * rl::DEG2RAD));
    rl::BoundingBox bounds = rl::getModelBoundingBox(model);

    rl::Camera camera = {
        { 
            bounds.min.x + bounds.max.x / 2.0f, 
            1.0f, 
            bounds.min.z + bounds.max.z / 2.0f, 
        },
        { 
            bounds.min.x + bounds.max.x / 2.0f, 
            0.0f, 
            bounds.min.z + bounds.max.z / 2.0f, 
        },
        { 0.0f, 0.0f, -1.0f },
        1.0f,
        rl::CameraProjection.ORTHOGRAPHIC
    };

    while (!rl::windowShouldClose())
    {
        rl::@drawing() {
            rl::clearBackground(rl::RAYWHITE);

            rl::@mode3D(camera) {
                rl::drawModel(
                    model, 
                    { 0.0f, 0.0f, 0.0f }, 
                    1.0f,
                    rl::WHITE
                );
            };
        };
    }

    return 0;
}


fn rl::Mesh gen_mesh_from_ttf_mesh(ttf::Mesh* ttf_mesh) {
    rl::Mesh mesh;

    /* Each triangle has three vertices */
    /* Each vertex is mapped to a 2D texture coordinate */
    mesh.triangleCount = ttf_mesh.nfaces;
    mesh.vertexCount = mesh.triangleCount * 3;
    mesh.vertices = (float*) mem::malloc(mesh.vertexCount * 3L * float.sizeof);
    mesh.texcoords = (float*) mem::malloc(mesh.vertexCount * 2L * float.sizeof);
    mesh.normals = (float*) mem::malloc(mesh.vertexCount * 3L * float.sizeof);

    int i;
    for (i = 0; i < mesh.triangleCount; i += 1) {
        CInt* face = ttf_mesh.faces + i;

        mesh.vertices[i * 9 + 0] = ttf_mesh.vert[face[0]][0];
        mesh.vertices[i * 9 + 1] = ttf_mesh.vert[face[0]][1];
        mesh.vertices[i * 9 + 2] = 0.0f;

        mesh.vertices[i * 9 + 3] = ttf_mesh.vert[face[1]][0];
        mesh.vertices[i * 9 + 4] = ttf_mesh.vert[face[1]][1];
        mesh.vertices[i * 9 + 5] = 0.0f;

        mesh.vertices[i * 9 + 6] = ttf_mesh.vert[face[2]][0];
        mesh.vertices[i * 9 + 7] = ttf_mesh.vert[face[2]][1];
        mesh.vertices[i * 9 + 8] = 0.0f;
    }

    mesh.texcoords[0:mesh.vertexCount] = 0.0f;
    mesh.texcoords[0:mesh.vertexCount] = 1.0f;

    rl::uploadMesh(&mesh, false);

    return mesh;
}


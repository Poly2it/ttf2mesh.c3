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


module ttf::c3;


fault FontMatchResult {
    FONT_MATCH_ALLOCATION_FAILED,
    FONT_NOT_FOUND,
}


fn ttf::File**! font_find_by_match(ZString pattern) {
    ttf::File** matches = ttf::list_system_fonts(pattern);

    if (matches == null) {
        return FontMatchResult.FONT_MATCH_ALLOCATION_FAILED?;
    }
    if (matches[0] == null) {
        return FontMatchResult.FONT_NOT_FOUND?;
    }

    return matches;
}


fault FontLoadResult {
    FONT_ALLOCATION_FAILED,
}


fn ttf::File*! font_load_by_filename(ZString filename, bool headers_only = false) {
    ttf::File* font;

    ttf::load_from_file(filename, &font, headers_only);
    if (font == null) {
        return FontLoadResult.FONT_ALLOCATION_FAILED?;
    }
    
    return font;
}


fault FontGlyphFindResult {
    GLYPH_NOT_FOUND,
}


fn CInt! ttf::File.find_glyph_index(ttf::File* self, Char32 glyph) {
    CInt index = ttf::find_glyph(self, glyph);
    if (index < 0) {
        return FontGlyphFindResult.GLYPH_NOT_FOUND?;
    }

    return index;
}


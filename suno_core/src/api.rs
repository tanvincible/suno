use crate::pipeline::TranslationPipeline;
use crate::utils::{AudioChunk, SunoError, Translation};
use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::ptr;
use std::sync::Arc;
use tokio::sync::mpsc;

// FFI-safe types
#[repr(C)]
pub struct FFIAudioChunk {
    pub data: *mut f32,
    pub length: usize,
    pub sample_rate: u32,
    pub channels: u16,
}

#[repr(C)]
pub struct FFITranslation {
    pub original: *mut c_char,
    pub translated: *mut c_char,
    pub confidence: f32,
}

// Global pipeline instance
static mut PIPELINE: Option<Arc<TranslationPipeline>> = None;

/// Initialize the Suno translation pipeline
#[no_mangle]
pub extern "C" fn suno_init(
    whisper_model_path: *const c_char,
    gemma_model_path: *const c_char,
    source_lang: *const c_char,
    target_lang: *const c_char,
) -> i32 {
    let whisper_path = unsafe { CStr::from_ptr(whisper_model_path) }
        .to_str()
        .unwrap();
    let gemma_path = unsafe { CStr::from_ptr(gemma_model_path) }
        .to_str()
        .unwrap();
    let src_lang = unsafe { CStr::from_ptr(source_lang) }.to_str().unwrap();
    let tgt_lang = unsafe { CStr::from_ptr(target_lang) }.to_str().unwrap();

    match TranslationPipeline::new(whisper_path, gemma_path, src_lang, tgt_lang) {
        Ok(pipeline) => {
            unsafe {
                PIPELINE = Some(Arc::new(pipeline));
            }
            0 // Success
        }
        Err(_) => -1, // Error
    }
}

/// Process audio chunk and get translation
#[no_mangle]
pub extern "C" fn suno_process_audio(
    audio_chunk: *const FFIAudioChunk,
    result: *mut FFITranslation,
) -> i32 {
    let pipeline = unsafe {
        match &PIPELINE {
            Some(p) => p.clone(),
            None => return -1,
        }
    };

    let chunk = unsafe {
        let ffi_chunk = &*audio_chunk;
        let data = std::slice::from_raw_parts(ffi_chunk.data, ffi_chunk.length);
        AudioChunk {
            data: data.to_vec(),
            sample_rate: ffi_chunk.sample_rate,
            channels: ffi_chunk.channels,
            timestamp: std::time::Duration::from_secs(0),
        }
    };

    // This would be async in real implementation
    // For FFI, we need to make it blocking or use callback
    match pipeline.process_audio_sync(chunk) {
        Ok(translation) => {
            unsafe {
                let original = CString::new(translation.original).unwrap();
                let translated = CString::new(translation.translated).unwrap();

                (*result).original = original.into_raw();
                (*result).translated = translated.into_raw();
                (*result).confidence = translation.confidence;
            }
            0
        }
        Err(_) => -1,
    }
}

/// Free memory allocated by Rust
#[no_mangle]
pub extern "C" fn suno_free_string(ptr: *mut c_char) {
    if !ptr.is_null() {
        unsafe {
            let _ = CString::from_raw(ptr);
        }
    }
}

/// Cleanup and shutdown
#[no_mangle]
pub extern "C" fn suno_cleanup() {
    unsafe {
        PIPELINE = None;
    }
}

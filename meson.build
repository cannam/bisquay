project(
    'Bisquay',
    'cpp',  # For the FFI bits; the SML code is built via "custom targets"
    default_options: [
      'cpp_std=c++14',
      'warning_level=3',
      'buildtype=release',
    ]
    )

run_target(
  'doc',
  command: 'scripts/doc.sh'
)

if meson.get_compiler('cpp').get_id() == 'msvc'
    add_global_arguments([
#        '-MT',
        '-D__MSVC__',
        '-DWIN32',
        '-DNOMINMAX',
        '-D_USE_MATH_DEFINES',
        '-DUNICODE',
        '-D__WINDOWS_MM__',
        '-Zc:wchar_t-',
        ],
        language: 'cpp'
    )
endif

if build_machine.system() == 'windows'

    platform_feature_defines = [
        '-DHAVE_IPP',
        '-DUSE_IPP_STATIC',
        '-DHAVE_LIBSAMPLERATE',
        '-DHAVE_PORTAUDIO',
        '-DHAVE_MEDIAFOUNDATION',
        '-DHAVE_OPUS',
        '-DAPPSTORE',
        '-DNDEBUG',
        '-DNO_THREAD_CHECKS',
    ]
    platform_feature_includedirs = [
        'ext/turbotdeps/win32-msvc/include',
        'ext/turbotdeps/win32-msvc/include/opus',
        'c:/Program Files (x86)/IntelSWTools/compilers_and_libraries/windows/ipp/include',
    ]
    platform_feature_libs = [
        '-NODEFAULTLIB:MSVCRT',
        '-L../ext/turbotdeps/win32-msvc/lib',
        '-LC:/Program Files (x86)/IntelSWTools/compilers_and_libraries/windows/ipp/lib/ia32',
        '-lippsmt', '-lippvmmt', '-lippcoremt',
        '-lportaudio', '-lsamplerate', '-lopusfile', '-lopusenc', '-lopus', '-logg', '-lmfplat', '-lmfreadwrite', '-lmfuuid', '-lpropsys', '-lws2_32', '-lgdi32', '-lcomdlg32', '-loleaut32', '-limm32', '-lwinmm', '-lwinspool', '-lole32', '-luser32', '-ladvapi32', '-lmsimg32', '-lshell32', '-lnetapi32', '-lwtsapi32', '-lkernel32', '-lversion', '-ldwmapi', '-luserenv', '-luuid',
    ]
    
elif build_machine.system() == 'darwin'

    add_global_arguments([
        '-mmacosx-version-min=10.13',
        ],
        language: 'cpp'
    )
    platform_feature_defines = [
        '-DHAVE_LIBSAMPLERATE',
        '-DHAVE_PORTAUDIO',
        '-DHAVE_COREAUDIO',
        '-DHAVE_VDSP',
        '-DHAVE_OPUS',
        '-DUSE_PTHREADS',
    ]
    platform_feature_includedirs = [
        'ext/turbotdeps/macos/include',
        'ext/turbotdeps/macos/include/opus',
    ]
    platform_feature_libs = [
        '-mmacosx-version-min=10.13',
        '-L../ext/turbotdeps/macos/lib-amd64',
	'-lsamplerate', '-lopusfile', '-lopusenc', '-lopus', '-logg', '-lportaudio',
	'-framework', 'Accelerate', '-framework', 'CoreAudio', '-framework', 'AudioUnit', '-framework', 'AudioToolbox',
    ]
    platform_general_libs = [
      '-lc++'
    ]

elif build_machine.system() == 'linux'

    platform_feature_defines = [
        '-DHAVE_IPP',
        '-DUSE_IPP_STATIC',
        '-DHAVE_LIBSAMPLERATE',
        '-DHAVE_PORTAUDIO',
        '-DHAVE_LIBPULSE',
        '-DHAVE_JACK',
        '-DDYNAMIC_JACK',
        '-DHAVE_OGGZ',
        '-DHAVE_FISHSOUND',
        '-DHAVE_OPUS',
        '-DUSE_PTHREADS',
    ]
    platform_feature_includedirs = [
        '/opt/intel/ipp/include',
        '/usr/include/opus',
    ]
    platform_feature_libs = [
        '-L/opt/intel/ipp/lib/intel64',
        '-Wl,-Bstatic', '-lipps', '-lippvm', '-lippcore', '-Wl,-Bdynamic',
        '-lcblas',
        '-lportaudio', '-lpulse', '-lsamplerate', '-lopusfile', '-lopusenc', '-lopus', '-loggz', '-lfishsound', '-logg', '-ldl', '-lz',
    ]
    platform_general_libs = [
      '-lpthread', '-lstdc++', '-lGL'
    ]
endif

    
bsq_test_files_sml_only = [
    'test-sml.mlb'
    ]

bsq_test_files_ffi = [
    'test-ffi.mlb'
    ]

bsq_test_output = [
    'bsq_test'
    ]

if get_option('sml_buildtype') == 'polyml'

    bsq_test_target = custom_target(
        'bsq_test',
        input: bsq_test_files_sml_only,
        output: bsq_test_output,
        depfile: 'bsq_test.deps',
        command: [
            meson.current_source_dir() / 'sml-buildscripts/with-mlb-dependencies',
            meson.current_source_dir() / 'sml-buildscripts/polybuild',
            '-o', '@OUTPUT@',
            '@INPUT@',
        ],
        build_by_default: true,
        )

elif get_option('sml_buildtype') == 'mlton_noffi'
    
    mlton = find_program('mlton')

    bsq_test_target = custom_target(
        'bsq_test',
        input: bsq_test_files_sml_only,
        output: bsq_test_output,
        depfile: 'bsq_test.deps',
        command: [
            meson.current_source_dir() / 'sml-buildscripts/with-mlb-dependencies',
            mlton,
            '-output', '@OUTPUT@',
            '@INPUT@',
        ],
        build_by_default: true,
        )

else

    bq_files = [
        'ext/bqaudioio/src/AudioFactory.cpp',
        'ext/bqaudioio/src/JACKAudioIO.cpp',
        'ext/bqaudioio/src/Log.cpp',
        'ext/bqaudioio/src/PortAudioIO.cpp',
        'ext/bqaudioio/src/PulseAudioIO.cpp',
        'ext/bqaudioio/src/ResamplerWrapper.cpp',
        'ext/bqaudioio/src/SystemPlaybackTarget.cpp',
        'ext/bqaudioio/src/SystemRecordSource.cpp',
        'ext/bqaudiostream/src/AudioReadStream.cpp',
        'ext/bqaudiostream/src/AudioReadStreamFactory.cpp',
        'ext/bqaudiostream/src/AudioStreamExceptions.cpp',
        'ext/bqaudiostream/src/AudioWriteStreamFactory.cpp',
        'ext/bqfft/src/FFT.cpp',
        'ext/bqresample/src/Resampler.cpp',
        'ext/bqvec/src/Allocators.cpp',
        'ext/bqvec/src/Barrier.cpp',
        'ext/bqvec/src/VectorOpsComplex.cpp',
        ]
    
    bq_inc = include_directories([
        'ext/bqaudioio',
        'ext/bqaudioio/bqaudioio',
        'ext/bqaudiostream',
        'ext/bqaudiostream/bqaudiostream',
        'ext/bqfft',
        'ext/bqfft/bqfft',
        'ext/bqresample',
        'ext/bqresample/bqresample',
        'ext/bqthingfactory',
        'ext/bqthingfactory/bqthingfactory',
        'ext/bqvec',
        'ext/bqvec/bqvec',
        ])
    
    bq_flags = [
        '-DNO_EXCEPTIONS',
        ]
    
    bq_lib = static_library(
        'bq',
        bq_files,
        include_directories: [
	    bq_inc,
	    platform_feature_includedirs,
        ],
        cpp_args: [
            bq_flags,
	    platform_feature_defines,
        ],
        build_by_default: false,
        )

    mlton = find_program('mlton')
    ar = find_program('ar')

    ffi_export_header_target = custom_target(
        'ffi_export_header',
        input: 'bsq-bq/ffi/export-bqaudioio.sml',
        output: 'export.h',
        command: [
            mlton, '-default-ann', 'allowFFI true',
            '-export-header', '@OUTPUT@', '-stop', 'tc', '@INPUT@']
        )
    
    ffi_impl_header_target = custom_target(
        'ffi_impl_header',
        input: 'bsq-bq/ffi/import-bqvec.sml',
        output: 'impl.h',
        command: [
            mlton, '-default-ann', 'allowFFI true',
            '-export-header', '@OUTPUT@', '-stop', 'tc', '@INPUT@']
        )
    
    ffi_bundle_archive = static_library(
        'ffi_bundle',
        [ 'bsq-bq/ffi/impl-bundle.cpp' ],
        [ ffi_export_header_target, ffi_impl_header_target ],
        include_directories: bq_inc,
        cpp_args: [
            bq_flags
        ],
        )
    
    ffi_bundle_target = custom_target(
        'ffi_bundle',
        input: ffi_bundle_archive,
        output: 'bsq-bq_ffi_impl-bundle.cpp.o',
        command: [
            ar,
        'x',
        '@INPUT@',
        '@OUTPUT@'
    ],
    )

    bsq_test_link_opts = []
    foreach opt : platform_feature_libs
        bsq_test_link_opts += '-link-opt'
	bsq_test_link_opts += opt
    endforeach
    foreach opt : platform_general_libs
        bsq_test_link_opts += '-link-opt'
	bsq_test_link_opts += opt
    endforeach

    mlton_profile_opts = []
    if get_option('sml_buildtype') == 'mlton_profile'
      mlton_profile_opts = [
        '-profile', 'time',
        '-profile-stack', 'true',
        '-profile-branch', 'true',
        '-profile-include', '<basis>',
      ]
    endif

    mlton_debug_opts = []
    if get_option('sml_buildtype') == 'mlton_debug'
      mlton_debug_opts = [
        '-const', 'Exn.keepHistory true',
      ]
    endif
        
    bsq_test_target = custom_target(
        'bsq_test',
        input: bsq_test_files_ffi,
        output: bsq_test_output,
        depfile: 'bsq_test.deps',
        command: [
            meson.current_source_dir() / 'sml-buildscripts/with-mlb-dependencies',
            mlton,
            mlton_profile_opts,
            mlton_debug_opts,
            '-default-ann', 'allowFFI true',
            '-default-ann', 'allowPrim true',
            '-link-opt', '-L.',
            '-link-opt', '-lbq',
	    bsq_test_link_opts,
            '-output', '@OUTPUT@',
            '@INPUT@',
            ffi_bundle_target,
            meson.current_source_dir() / 'sml-stringinterpolate/strfromd.c',
        ],
        depends: [
            bq_lib,
            ffi_bundle_target,
        ],
        build_by_default: true,
    )

endif

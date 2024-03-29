project(
  'Bisquay',
  'cpp',  # For the FFI bits; the SML code is built via "custom targets"
  default_options: [
    'cpp_std=c++14',
    'warning_level=3',
    'buildtype=release',
  ]
)

system = host_machine.system()
architecture = host_machine.cpu_family()

ipp_path = get_option('ipp_path')
sml_buildtype = get_option('sml_buildtype')
mlton_extra_args = get_option('mlton_extra_args')

run_target(
  'doc',
  command: meson.current_source_dir() / 'scripts/doc.sh'
)

if meson.get_compiler('cpp').get_id() == 'msvc'
  add_global_arguments(
    [
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

if system == 'windows'

  platform_feature_defines = [
    '-DUSE_BUILTIN_FFT',
    '-DUSE_BQRESAMPLER',
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
  ]
  platform_feature_libs = [
    '-NODEFAULTLIB:MSVCRT',
    '-L../ext/turbotdeps/win32-msvc/lib',
    '-lportaudio', '-lsamplerate', '-lopusfile', '-lopusenc', '-lopus', '-logg', '-lmfplat', '-lmfreadwrite', '-lmfuuid', '-lpropsys', '-lws2_32', '-lgdi32', '-lcomdlg32', '-loleaut32', '-limm32', '-lwinmm', '-lwinspool', '-lole32', '-luser32', '-ladvapi32', '-lmsimg32', '-lshell32', '-lnetapi32', '-lwtsapi32', '-lkernel32', '-lversion', '-ldwmapi', '-luserenv', '-luuid',
  ]

  if ipp_path != ''
    platform_feature_defines += [
      '-DHAVE_IPP',
    ]
    platform_feature_includedirs += [
      ipp_path / 'include'
    ]
    platform_feature_libs += [
      '-L' + (ipp_path / 'lib/intel64'),
      '-lippsmt', '-lippvmmt', '-lippcoremt',
    ]
  endif
  
elif system == 'darwin'

  add_global_arguments([
                        '-mmacosx-version-min=10.13',
                      ],
                       language: 'cpp'
                      )
  platform_feature_defines = [
    '-DUSE_BQRESAMPLER',
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
  
  if architecture == 'aarch64'
    add_global_arguments(
      [
	'-mmacosx-version-min=11',
	'-arch', 'arm64'
      ],
      language: 'cpp'
    )
    platform_feature_libs = [
      '-mmacosx-version-min=11',
      '-arch', 'arm64',
      '-L../ext/turbotdeps/macos/lib-arm64',
      '-lc++'
    ]
  elif architecture == 'x86_64'
    add_global_arguments(
      [
	'-mmacosx-version-min=10.13',
	'-arch', 'x86_64',
      ],
      language: 'cpp'
    )
    platform_feature_libs = [
      '-mmacosx-version-min=10.13',
      '-arch', 'x86_64',
      '-L../ext/turbotdeps/macos/lib-amd64',
      '-lc++'
    ]
  else # begin architecture != 'aarch64' or 'x86_64'
    error('Build for architecture ' + architecture + ' is not supported on this platform')
  endif # end architecture

  platform_feature_libs += [
    '-lsamplerate', '-lopusfile', '-lopusenc', '-lopus', '-logg', '-lportaudio',
    '-framework', 'Accelerate', '-framework', 'CoreAudio',
    '-framework', 'AudioUnit', '-framework', 'AudioToolbox',
    '-framework', 'CoreFoundation', '-framework', 'CoreServices',
  ]
  platform_general_libs = [
    '-lc++'
  ]

  if ipp_path != ''
    error('IPP is not used on this platform, ipp_path should be left empty')
  endif

elif system == 'linux'

  platform_feature_defines = [
    '-DUSE_BUILTIN_FFT',
    '-DUSE_BQRESAMPLER',
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
    '/usr/include/opus',
  ]
  platform_feature_libs = [
    '-lcblas',
    '-lportaudio', '-lpulse', '-lopusfile', '-lopusenc', '-lopus', '-loggz', '-lfishsound', '-logg', '-ldl', '-lz',
  ]
  platform_general_libs = [
    '-lpthread', '-lstdc++',
  ]

  if ipp_path != ''
    platform_feature_defines += [
      '-DHAVE_IPP',
    ]
    platform_feature_includedirs += [
      ipp_path / 'include'
    ]
    platform_feature_libs += [
      '-L' + (ipp_path / 'lib/intel64'),
      '-Wl,-Bstatic', '-lipps', '-lippvm', '-lippcore', '-Wl,-Bdynamic',
    ]
  endif # end ipp_path

endif


sml_buildscripts = meson.current_source_dir() / 'sml-buildscripts'

if system == 'windows'
  bsq_test_name = 'bsq_test.exe'
  bsq_perftest_name = 'bsq_perftest.exe'
  mlb_deps_program = sml_buildscripts / 'with-mlb-dependencies.bat'
  polybuild_program = sml_buildscripts / 'polybuild.bat'
  mlton_program = meson.current_source_dir() / 'ext/mlton-cutdown/windows/mlton.bat'
  if meson.get_compiler('cpp').get_id() == 'msvc'
    cl_gnu_compatibility_hack_defines = [
      '-D__attribute__=;//',
    ]
  else
    cl_gnu_compatibility_hack_defines = []
  endif
else
  bsq_test_name = 'bsq_test'
  bsq_perftest_name = 'bsq_perftest'
  mlb_deps_program = sml_buildscripts / 'with-mlb-dependencies'
  polybuild_program = sml_buildscripts / 'polybuild'
  mlton_program = find_program('mlton')
  cl_gnu_compatibility_hack_defines = []
endif

bsq_test_files_sml_only = [
  'test-sml.mlb'
]

bsq_test_files_ffi = [
  'test-ffi.mlb'
]

bsq_test_output = [
  bsq_test_name
]

perftest_files_sml_only = [
  'bsq-perftest/perftest-sml.mlb'
]

perftest_files_ffi = [
  'bsq-perftest/perftest-ffi.mlb'
]

perftest_output = [
  bsq_perftest_name
]

if sml_buildtype == 'polyml'

  bsq_test_target = custom_target(
    'bsq_test',
    input: bsq_test_files_sml_only,
    output: bsq_test_output,
    depfile: 'bsq_test.deps',
    command: [
      mlb_deps_program,
      polybuild_program,
      '-o', '@OUTPUT@',
      '@INPUT@',
    ],
    build_by_default: true,
  )

  perftest_target = custom_target(
    'bsq_perftest',
    input: perftest_files_sml_only,
    output: perftest_output,
    depfile: 'bsq_perftest.deps',
    command: [
      mlb_deps_program,
      polybuild_program,
      '-o', '@OUTPUT@',
      '@INPUT@',
    ],
    build_by_default: true,
  )

elif sml_buildtype == 'mlton_noffi'
  
  bsq_test_target = custom_target(
    'bsq_test',
    input: bsq_test_files_sml_only,
    output: bsq_test_output,
    depfile: 'bsq_test.deps',
    command: [
      mlb_deps_program,
      mlton_program,
      mlton_extra_args,
      '-default-type', 'int64',
      '-disable-pass', 'deepFlatten',
      '-output', '@OUTPUT@',
      '@INPUT@',
    ],
    build_by_default: true,
  )

  perftest_target = custom_target(
    'bsq_perftest',
    input: perftest_files_sml_only,
    output: perftest_output,
    depfile: 'bsq_perftest.deps',
    command: [
      mlb_deps_program,
      mlton_program,
      mlton_extra_args,
      '-default-type', 'int64',
      '-disable-pass', 'deepFlatten',
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
    'ext/bqresample/src/BQResampler.cpp',
    'ext/bqresample/src/common.cpp',
    'ext/bqvec/src/Allocators.cpp',
    'ext/bqvec/src/Barrier.cpp',
    'ext/bqvec/src/VectorOpsComplex.cpp',
  ]
  
  bq_inc = include_directories(
    [
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

  cp = find_program('cp')

  ffi_export_header_target = custom_target(
    'ffi_export_header',
    input: 'bsq-bq/ffi/export-bqaudioio.sml',
    output: 'export.h',
    command: [
      mlb_deps_program,
      mlton_program,
      mlton_extra_args,
      '-default-type', 'int64',
      '-default-ann', 'allowFFI true',
      '-export-header', '@OUTPUT@',
      '-stop', 'tc',
      '@INPUT@']
  )
  
  ffi_impl_header_target = custom_target(
    'ffi_impl_header',
    input: 'bsq-bq/ffi/import-bqvec.sml',
    output: 'impl.h',
    command: [
      mlb_deps_program,
      mlton_program,
      mlton_extra_args,
      '-default-type', 'int64',
      '-default-ann', 'allowFFI true',
      '-export-header', '@OUTPUT@',
      '-stop', 'tc',
      '@INPUT@']
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
      cp,
      '@INPUT@.p/bsq-bq_ffi_impl-bundle.cpp.o',
      '@OUTPUT@'
    ],
  )

  mlton_link_opts = []
  foreach opt : platform_feature_libs
    mlton_link_opts += '-link-opt-quote'
    mlton_link_opts += opt
  endforeach
  foreach opt : platform_general_libs
    mlton_link_opts += '-link-opt-quote'
    mlton_link_opts += opt
  endforeach

  mlton_profile_opts = []
  if sml_buildtype == 'mlton_profile'
    mlton_profile_opts = [
      '-profile', 'time',
      '-profile-stack', 'true',
      '-profile-branch', 'true',
      '-profile-include', '<basis>',
    ]
  endif

  mlton_debug_opts = []
  if sml_buildtype == 'mlton_debug'
    mlton_debug_opts = [
      '-const', 'Exn.keepHistory true',
      '-cc-opt', '-g',
      '-link-opt', '-g',
    ]
  endif

  mlton_system_opts = [
      '-chunk-tail-call', 'false',
  ]

  if system == 'darwin'
    if architecture == 'aarch64'
      mlton_system_opts += [
        '-codegen', 'c',
        '-cc-opt', '-mmacosx-version-min=11',
      ]
    elif architecture == 'x86_64'
      mlton_system_opts += [
        '-codegen', 'c',
	'-cc-opt', '-mmacosx-version-min=10.13',
      ]
    endif
  endif
  
  bsq_test_target = custom_target(
    'bsq_test',
    input: bsq_test_files_ffi,
    output: bsq_test_output,
    depfile: 'bsq_test.deps',
    command: [
      mlb_deps_program,
      mlton_program,
      mlton_extra_args,
      mlton_system_opts,
      mlton_profile_opts,
      mlton_debug_opts,
      '-default-type', 'int64',
      '-default-ann', 'allowFFI true',
      '-default-ann', 'allowPrim true',
      '-disable-pass', 'deepFlatten',
      '-link-opt', '-L.',
      '-link-opt', '-lbq',
      mlton_link_opts,
      '-output', '@OUTPUT@',
      '@INPUT@',
      ffi_bundle_target,
      meson.current_source_dir() / 'sml-stringinterpolate/number-string.c',
      meson.current_source_dir() / 'bsq-matrix/ffi/copyvec.c',
      meson.current_source_dir() / 'bsq-rrloop/ffi/rr-support.c',
      meson.current_source_dir() / 'bsq-signalbits/ffi/window-post.c',
    ],
    depends: [
      bq_lib,
      ffi_bundle_target,
    ],
    build_by_default: true,
  )
  
  perftest_target = custom_target(
    'bsq_perftest',
    input: perftest_files_ffi,
    output: perftest_output,
    depfile: 'bsq_perftest.deps',
    command: [
      mlb_deps_program,
      mlton_program,
      mlton_extra_args,
      mlton_system_opts,
      '-codegen', 'c',
      mlton_profile_opts,
      mlton_debug_opts,
      '-default-type', 'int64',
      '-default-ann', 'allowFFI true',
      '-default-ann', 'allowPrim true',
      '-disable-pass', 'deepFlatten',
      '-link-opt', '-L.',
      '-link-opt', '-lbq',
      mlton_link_opts,
      '-output', '@OUTPUT@',
      '@INPUT@',
      ffi_bundle_target,
      meson.current_source_dir() / 'sml-stringinterpolate/number-string.c',
      meson.current_source_dir() / 'bsq-matrix/ffi/copyvec.c',
      meson.current_source_dir() / 'bsq-rrloop/ffi/rr-support.c',
      meson.current_source_dir() / 'bsq-signalbits/ffi/window-post.c',
    ],
    depends: [
      bq_lib,
      ffi_bundle_target,
    ],
    build_by_default: true,
  )

endif


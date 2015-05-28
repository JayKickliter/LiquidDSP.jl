using BinDeps

@BinDeps.setup

liquiddsp = library_dependency("liquiddsp", aliases = ["libliquid.dylib", "libliquid.so", "libliquid.dll"])

url     = "https://github.com/jgaeddert/liquid-dsp/archive/master.tar.gz"
depsdir = BinDeps.depsdir(liquiddsp)
srcdir  = joinpath(depsdir, "src", "liquid-dsp-master")
prefix  = joinpath(depsdir, "usr")

@unix_only  libfilename = "libliquid.so"
@osx_only   libfilename = "libliquid.dylib"

provides(Sources, URI(url), liquiddsp, unpacked_dir="liquid-dsp-master")

provides(SimpleBuild,
    (@build_steps begin
        GetSources(liquiddsp)
        CreateDirectory(prefix)
        @build_steps begin
            ChangeDirectory(srcdir)
            FileRule( joinpath(prefix, "lib", libfilename),
            @build_steps begin
                `sh bootstrap.sh`
                `sh configure --prefix=$prefix --enable-fftoverride`
                `make`
                `make install`
            end)
        end
    end), liquiddsp, os = :Unix)

@BinDeps.install @compat Dict(:liquiddsp => :liquiddsp)

using BinDeps

@BinDeps.setup

libliquid = library_dependency("libliquid")

provides(Sources,
         URI("https://github.com/jgaeddert/liquid-dsp/archive/master.tar.gz"),
         libliquid,
         unpacked_dir = "liquid-dsp-master")

liquidsrcdir = joinpath(srcdir(libliquid), "liquid-dsp-master")
prefix       = joinpath(BinDeps.depsdir(libliquid),"usr")


provides(SimpleBuild,
    (@build_steps begin
        GetSources(libliquid)
        CreateDirectory(prefix)
        @build_steps begin
            ChangeDirectory(liquidsrcdir)
            FileRule(joinpath(prefix,"lib","libliquid.dylib"),@build_steps begin
                `sh bootstrap.sh`
                `sh configure`
                `sed -i.bak s/HAVE_FFTW3_H\ 1/HAVE_FFTW3_H\ 0/g config.h`
                `make`
                `mkdir $prefix/lib`
                `cp libliquid.dylib $prefix/lib`
                `cp libliquid.a $prefix/lib`
            end)
        end
    end),libliquid, os = :Unix)

@BinDeps.install Dict(:libliquid => :libliquid)

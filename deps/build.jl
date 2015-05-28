using BinDeps

@BinDeps.setup

liquid = library_dependency("libliquid")

@BinDeps.if_install begin

provides(Sources,
         URI("https://github.com/jgaeddert/liquid-dsp/archive/master.tar.gz"),
         liquid,
         unpacked_dir = "liquid")

pngbuilddir = joinpath(BinDeps.depsdir(liquid),"builds","libpng-$png_version")

provides(BuildProcess,
	(@build_steps begin
		GetSources(liquid)
		CreateDirectory(liquidbuilddir)
		@build_steps begin
			ChangeDirectory(liquidbuilddir)
			FileRule(joinpath(prefix,"lib","libpng15.dll"),@build_steps begin
				`cmake -DCMAKE_INSTALL_PREFIX="$prefix" -G"MSYS Makefiles" $pngsrcdir`
				`make`
				`cp libpng*.dll $prefix/lib`
				`cp libpng*.a $prefix/lib`
				`cp libpng*.pc $prefix/lib/pkgconfig`
				`cp pnglibconf.h $prefix/include`
				`cp $pngsrcdir/png.h $prefix/include`
				`cp $pngsrcdir/pngconf.h $prefix/include`
			end)
		end
	end),liquid, os = :Darwin)


@BinDeps.install

end

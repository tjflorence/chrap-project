geno(1).strterm = '*Empty*'
geno(1).p = 1;
geno(2).strterm = '*Gr28*'
geno(2).p = 1;
geno(3).strterm = '*HC*'
geno(3).p = 1;

%% Collect experiment files
datadir = '';

cd(datadir)
dayfiles = dir('2016*');

for ii = 1:length(dayfiles)

	cd(dayfiles(ii).name)

		for jj = 1:length(geno)

				gytpe_exp = dir(geno(jj).strterm);
				for kk = 1:length(gtype_exp)

						geno(jj).exps(geno(jj).p).expdir = [datadir '/' dayfiles(ii).name ...
						'/' gtype_exp(kk).name];

						geno(jj).p = geno(jj).p+1;

				end



		end

	cd('..')

end
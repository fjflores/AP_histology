function probe_ccf = trprobeccf( probe_ccf )

nProbes = length( probe_ccf );
for probeIdx = 1 : nProbes
    oldPoints = probe_ccf( probeIdx ).points;
    points = ccf2pax( oldPoints );
    probe_ccf( probeIdx ).points = points;

end

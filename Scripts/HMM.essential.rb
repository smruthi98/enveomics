#!/usr/bin/env ruby

# @author  Luis M. Rodriguez-R
# @license artistic license 2.0

$:.push File.expand_path('../lib', __FILE__)
require 'enveomics_rb/enveomics'
use 'tmpdir'
use 'zlib'

o = {
  bin: '', thr: 2, q: false, stats: true, genes: true, bacteria: false,
  archaea: false, genomeeq: false, metagenome: false, list: false,
  collection: 'dupont_2012'
}
OptionParser.new do |opts|
  opts.banner = "
Finds and extracts a collection of essential proteins suitable for genome
completeness evaluation and phylogenetic analyses. Important note: most complete
bacterial genomes contain only 106/111 genes in this collection, therefore
producing a completeness of 95.5%, and most archaeal genomes only contain 26/111
genes, producing a completeness of 23.4%. Use the options --bacteria and/or 
--archaea to ignore models often missing in one or both domains. Note that even
with these options, some complete archaeal genomes result in very low values of
completeness (e.g., Nanoarchaeum equitans returns 88.5%).

Requires HMMer 3.0+ (http://hmmer.janelia.org/software).

Usage: #{$0} [options]"
  opts.separator ''
  opts.separator 'Mandatory'
  opts.on(
    '-i', '--in FILE',
    'Path to the FastA file (.gz allowed) with all the proteins in a genome'
  ) { |v| o[:in] = v }
  opts.separator ''
  opts.separator 'Options'
  opts.on(
    '-c', '--collection STR',
    'Reference collection of essential proteins to use. One of:',
    '> dupont_2012 (default): https://doi.org/10.1038/ismej.2011.189',
    '  modified by https://doi.org/10.1038/ismej.2015.5',
    '> lee_2019: https://doi.org/10.1093/bioinformatics/btz188',
    '  modified by https://doi.org/10.7717/peerj.1319'
  ) { |v| o[:collection] = v }
  opts.on(
    '-o', '--out FILE',
    'Path to the output FastA file with the translated essential genes',
    'By default the file is not produced'
  ) { |v| o[:out] = v }
  opts.on(
    '-m', '--per-model STR',
    'Prefix of translated genes in independent files with the name of the',
    'model appended. By default files are not produced'
  ) { |v| o[:permodel] = v }
  opts.on(
    '-R', '--report FILE',
    'Path to the report file. By default, the report is sent to the STDOUT'
  ) { |v| o[:report] = v }
  opts.on(
    '--hmm-out FILE',
    'Save HMMsearch output in this file. By default, not saved'
  ) { |v| o[:hmmout] = v }
  opts.on(
    '--alignments FILE',
    'Save the aligned proteins in this file. By default, not saved'
  ) { |v| o[:alignments] = v }
  opts.on(
    '-B', '--bacteria',
    'If set, ignores models typically missing in Bacteria'
  ) { |v| o[:bacteria] = v }
  opts.on(
    '-A', '--archaea',
    'If set, ignores models typically missing in Archaea'
  ) { |v| o[:archaea] = v }
  opts.on(
    '-G', '--genome-eq',
    'If set, ignores models not suitable for genome-equivalents estimations',
    'See Rodriguez-R et al, 2015, ISME J 9(9):1928-1940'
  ) { |v| o[:genomeeq] = v }
  opts.on(
    '-r', '--rename STR',
    'If set, renames the sequences with the string provided and appends it',
    'with pipe and the gene name (except in --per-model files)'
  ) { |v| o[:rename] = v }
  opts.on(
    '-n', '--no-stats',
    'If set, no statistics are reported on genome evaluation'
  ) { |v| o[:stats] = v }
  opts.on(
    '-s', '--no-genes',
    'If set, statistics won\'t include the lists of missing/multi-copy genes'
  ) { |v| o[:genes] = v }
  opts.on(
    '-M', '--metagenome',
    'If set, it allows for multiple copies of each gene and turns on',
    'metagenomic report mode'
  ) { |v| o[:metagenome] = v }
  opts.separator ''
  opts.separator 'Other Options'
  opts.on(
    '-L', '--list-models',
    'If set, it only lists the models and exits. Compatible with -A, -B, -G,',
    'and -q; ignores all other parameters'
  ) { |v| o[:list] = v }
  opts.on(
    '-b', '--bin DIR',
    'Path to the directory containing the binaries of HMMer 3.0+'
  ) { |v| o[:bin] = v }
  opts.on(
    '--model-file',
    'External file containing models to search'
  ) { |v| o[:model_file] = v }
  opts.on(
    '-t', '--threads INT', Integer,
    "Number of parallel threads to be used.  By default: #{o[:thr]}"
  ) { |v| o[:thr] = v }
  opts.on('-q', '--quiet', 'Run quietly (no STDERR output)'){ o[:q] = true }
  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
  opts.separator ''
end.parse!
abort '-i is mandatory' if o[:in].nil? and not o[:list]
o[:bin] = o[:bin] + '/' if o[:bin].size > 0
o[:rename] = nil if o[:metagenome]

case o[:collection]
when 'dupont_2012'
  not_in_archaea = %w{GrpE Methyltransf_5 TIGR00001 TIGR00002 TIGR00009
  TIGR00019 TIGR00029 TIGR00043 TIGR00059 TIGR00060 TIGR00061 TIGR00062
  TIGR00082 TIGR00086 TIGR00092 TIGR00115 TIGR00116 TIGR00152 TIGR00158
  TIGR00165 TIGR00166 TIGR00168 TIGR00362 TIGR00388 TIGR00396 TIGR00409
  TIGR00418 TIGR00420 TIGR00422 TIGR00436 TIGR00459 TIGR00460 TIGR00472
  TIGR00487 TIGR00496 TIGR00575 TIGR00631 TIGR00663 TIGR00775 TIGR00810
  TIGR00855 TIGR00922 TIGR00952 TIGR00959 TIGR00963 TIGR00964 TIGR00967
  TIGR00981 TIGR01009 TIGR01011 TIGR01017 TIGR01021 TIGR01024 TIGR01029
  TIGR01030 TIGR01031 TIGR01032 TIGR01044 TIGR01049 TIGR01050 TIGR01059
  TIGR01063 TIGR01066 TIGR01067 TIGR01071 TIGR01079 TIGR01164 TIGR01169
  TIGR01171 TIGR01391 TIGR01393 TIGR01632 TIGR01953 TIGR02012 TIGR02013
  TIGR02027 TIGR02191 TIGR02350 TIGR02386 TIGR02387 TIGR02397 TIGR02432
  TIGR02729 TIGR03263 TIGR03594}
  not_in_bacteria = %w{TIGR00389 TIGR00408 TIGR00471 TIGR00775 TIGR02387}
  not_as_genomeeq = %w{TIGR02386 TIGR02387 TIGR00471 TIGR00472 TIGR00408
  TIGR00409 TIGR00389 TIGR00436 tRNA-synth_1d}
when 'lee_2019'
  not_in_archaea = %w{ADK AICARFT_IMPCHas ATP-synt ATP-synt_A Chorismate_synt
  EF_TS eIF-1a Exonuc_VII_L GrpE IPPT OSCP Pept_tRNA_hydro PGK RBFA RecO_C
  Ribonuclease_P Ribosomal_L17 Ribosomal_L18p Ribosomal_L19 Ribosomal_L20
  Ribosomal_L21p ribosomal_L24 Ribosomal_S3_C Ribosomal_L5 Ribosomal_L2
  Ribosomal_L27 Ribosomal_L27A Ribosomal_L28 Ribosomal_L32p Ribosomal_L35p
  Ribosomal_L9_C Ribosomal_S10 Ribosomal_S16 Ribosomal_S20p Ribosomal_S6
  RNA_pol_L RRF RsfS RuvX SecE SecG SmpB tRNA_m1G_MT TsaE UPF0054 YajC}
  not_in_bacteria = %w{AdoHcyase Archease ATP-synt_D ATP-synt_F CarS-like
  CTP-dep_RFKase Diphthamide_syn DNA_primase_lrg dsDNA_bind DUF357 DUF359
  DUF655 eIF-6 FbpA HMG-CoA_red NDK PPS_PS Prefoldin PTH2 PyrI Ribosomal_L15e
  Ribosomal_L21e Ribosomal_L26 Ribosomal_L31e Ribosomal_L32e Ribosomal_L37ae
  Ribosomal_L39 Ribosomal_L44 Ribosomal_L5e Ribosomal_S17e Ribosomal_S19e
  Ribosomal_S24e Ribosomal_S27e Ribosomal_S28e Ribosomal_S3Ae Ribosomal_S8e
  Rib_5-P_isom_A RNase_HII RNA_pol_L_2 RNA_pol_N RNA_pol_Rpb4 RtcB Spt4 TIM
  Trm56 tRNA-synt_1c tRNA-synt_His TruD vATP-synt_AC39 vATP-synt_E V_ATPase_I}
  not_as_genomeeq = not_in_archaea + not_in_bacteria
else
  raise "Unsupported collection: '#{o[:collection]}'"
end

begin
  Dir.mktmpdir do |dir|
    $stderr.puts "Temporal directory: #{dir}." unless o[:q]
    if o[:in] =~ /\.gz/
      tmp_in = File.expand_path('sequences.fa', dir)
      Zlib::GzipReader.open(o[:in]) do |ifh|
        File.open(tmp_in, 'w') { |ofh| ofh.print ifh.read }
      end
      o[:in] = tmp_in
    end

    # Create database.
    $stderr.puts 'Searching models.' unless o[:q]
    models = {}
    model_id = nil
    dbh = File.open("#{dir}/essential.hmm", 'w')
    o[:model_file] ||= File.expand_path(
      "../lib/data/#{o[:collection]}_essential.hmm.gz", __FILE__)
    mfh = (File.extname(o[:model_file]) == '.gz') ?
      Zlib::GzipReader.open(o[:model_file]) :
      File.open(o[:model_file], 'r')
    while ln = mfh.gets
      dbh.print ln
      ln.chomp!
      model_id = $1 if ln =~ /^NAME\s+(.+)/
      models[model_id] = $1 if ln =~ /^DESC\s+(.+)/
    end
    dbh.close
    mfh.close
    models.delete_if { |m| not_in_archaea.include? m  } if o[:archaea]
    models.delete_if { |m| not_in_bacteria.include? m } if o[:bacteria]
    models.delete_if { |m| not_as_genomeeq.include? m } if o[:genomeeq]
    if o[:list]
      models.each_pair{ |id,desc| puts [id,desc].join("\t") }
      exit
    end

    # Check HMMer version and run HMMsearch.
    if `"#{o[:bin]}hmmsearch" -h`.lines[1] !~ /HMMER 3/
      raise 'You have provided an unsupported version of HMMER. ' +
        'This script requires HMMER 3.0+.'
    end
    o[:hmmout] ||= "#{dir}/hmmsearch"
    `'#{o[:bin]}hmmsearch' --cpu #{o[:thr]} --tblout '#{o[:hmmout]}' \
      -A '#{dir}/a.sto' --cut_tc --notextw '#{dir}/essential.hmm' '#{o[:in]}' \
      > '#{dir}/hmmsearch.log'`

    # Parse output
    $stderr.puts 'Parsing results.' unless o[:q]
    trash = []
    genes = {}
    File.open(o[:hmmout], 'r') do |resh|
      while ln = resh.gets
         next if ln =~ /^#/
         r = ln.split /\s+/
         next unless models.include? r[2]
         if o[:metagenome]
           genes[ r[2] ] = [] if genes[ r[2] ].nil?
           genes[ r[2] ] << r[0]
         elsif genes[ r[2] ].nil?
           genes[ r[2] ] = r[0]
         else
           trash << r[2]
         end
      end
    end

    # Report statistics
    if o[:stats]
      reph = o[:report].nil? ? $stdout : File.open(o[:report], 'w')
      modifiers = [:bacteria, :archaea, :genomeeq]
        .map { |i| o[i] ? i.to_s[0].upcase : '' }.join('')
      reph.puts "! Collection: #{o[:collection]} #{modifiers}"
      if o[:metagenome]
        reph.printf "! Essential genes found: %d/%d.\n", genes.size, models.size
        gc = [0] * (models.size - genes.size) +
          genes.values.map{ |g| g.length }.sort
        reph.printf "! Mean number of copies per model: %.3f.\n",
          gc.inject(:+).to_f / models.size
        reph.printf "! Median number of copies per model: %.1f.\n",
          gc.size.even? ? gc[gc.size/2, 2].inject(:+).to_f / 2 : gc[gc.size/2]
        if o[:genes] and genes.size != models.size
          reph.printf "! Missing genes: %s\n",
            ([''] + models.keys.select{ |m| not genes.keys.include? m }.
                  map{|m| "#{m}: #{models[m]}."}).join("\n!   ")
        end
      else
        reph.printf "! Essential genes found: %d/%d.\n", genes.size, models.size
        reph.printf "! Completeness: %.1f%%.\n",
          100.0 * genes.size / models.size
        reph.printf "! Contamination: %.1f%%.\n",
          100.0 * trash.size / models.size
        if o[:genes]
          reph.printf "! Multiple copies: %s\n",
            ([''] + trash.uniq.
                  map{ |m| "#{trash.count(m)+1} #{m}: #{models[m]}." }).
                  join("\n!   ") unless trash.empty?
          reph.printf "! Missing genes: %s\n",
            ([''] + models.keys.select{ |m| not genes.keys.include? m }.
                  map{ |m| "#{m}: #{models[m]}." }).
                  join("\n!   ") unless genes.size == models.size
        end
      end
      reph.close unless o[:report].nil?
    end

    # Extract sequences
    unless o[:out].nil? and o[:permodel].nil?
      $stderr.puts 'Extracting sequences.' unless o[:q]
      faah = File.open(o[:in], 'r')
      outh = o[:out].nil? ? nil : File.open(o[:out], 'w')
      geneh = nil
      in_gene = nil
      unless o[:permodel].nil?
        genes.keys.each do |m|
          File.open("#{o[:permodel]}#{m}.faa", 'w').close
        end
      end
      while ln = faah.gets
        if ln =~ /^>(\S+)/
          if o[:metagenome]
            in_gene = genes.keys.
              map{ |k| genes[k].include?($1) ? k : nil }.compact.first
            in_gene = [in_gene, $1] unless in_gene.nil?
          else
            in_gene = genes.rassoc($1)
          end
          next if in_gene.nil?
          geneh.close unless geneh.nil?
          geneh = File.open("#{o[:permodel]}#{in_gene[0]}.faa", 'a+') unless
            o[:permodel].nil?
          outh.print(o[:rename].nil? ?
            ln : ">#{o[:rename]}|#{in_gene[0]}\n") unless outh.nil?
          geneh.print(o[:rename].nil? ? ln : ">#{o[:rename]}\n") unless
            geneh.nil?
        else
          next if in_gene.nil?
          outh.print ln unless outh.nil?
          geneh.print ln unless geneh.nil?
        end
      end
      geneh.close unless geneh.nil?
      outh.close unless outh.nil?
      faah.close
    end

    unless o[:alignments].nil?
      aln = {}
      File.open("#{dir}/a.sto", 'r') do |fh|
        cur_model = nil
        mask = []
        fh.each_line do |ln|
          case ln.chomp
          when /^# STOCKHOLM/
            cur_model = nil
            mask = []
          when /^#=GS (\S+)\/([\d\-]+)\s+DE/
            cur_model ||= ( genes.rassoc($1) || [] ).first
            aln[ cur_model ] ||= [ "# #{cur_model} : #{$1} : #{$2}" ]
          when /^#=GC RF\s+(\S+)/
            aln[ cur_model ][ 1 ] ||= $1.upcase.tap do |i|
              mask.each{ |d| i[d] = '' }
            end
          when /^[^#]\S*\s+(\S+)/
            next if aln[ cur_model ][ 2 ]
            aln[ cur_model ][ 2 ] = $1.upcase
            mask = aln[ cur_model ][ 2 ].split('').each_with_index.
                map{ |v, k| v == '.' ? k : nil }.compact.reverse
            aln[ cur_model ][ 2 ].delete!('.') unless mask.empty?
          end
        end
      end
      File.open(o[:alignments], 'w') do |fh|
        aln.each { |k, v| v.each{ |i| fh.puts i } }
      end
    end

    $stderr.puts 'Done.' unless o[:q]
  end # |dir|
rescue => err
  $stderr.puts "Exception: #{err}\n\n"
  err.backtrace.each { |l| $stderr.puts l + "\n" }
  err
end

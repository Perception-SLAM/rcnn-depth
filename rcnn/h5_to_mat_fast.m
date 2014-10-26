function h5_to_mat(h5_file, imdb, window_file, output_dir)
  pt = load(window_file);
  roidb = imdb.roidb_func(imdb);
 
  fid = H5F.open(h5_file);
  
  a_counter = 0;
  dset_id = H5D.open(fid, sprintf('/data-%06d', a_counter)); a = H5D.read(dset_id); H5D.close(dset_id);
  rem = size(a, 4);
  for i = 1:length(roidb.rois),
    d = roidb.rois(i);
    assert(isequal(pt.imlist{i}, imdb.image_ids{i}));
    assert(isequal(single(pt.list{i}(:,3:6)+1), d.boxes));
   
    while rem < size(d.boxes,1),
      a_counter = a_counter+1;
      dset_id = H5D.open(fid, sprintf('/data-%06d', a_counter)); a_new = H5D.read(dset_id); H5D.close(dset_id);
      % a_new = read_h5_file(h5_file, sprintf('data-%06d', a_counter)); a_new = a_new{1};
      a = cat(4, a, a_new);
      rem = size(a,4);
      fprintf('%d (%d), ', rem, a_counter);
    end
    fprintf('\n');
    f = a(:,:,:,[1:size(d.boxes,1)]);
    a = a(:,:,:, size(d.boxes,1)+1:end);
    rem = size(a,4);
    d.feat = permute(f, [4 3 1 2]);
    save_file = [output_dir imdb.image_ids{i} '.mat'];
    save(save_file, '-STRUCT', 'd');
  end
  H5F.close(fid);
end

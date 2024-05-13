% Routine to show normals HAS SCALE INCORPORATED
% arrows also scalled by 0.5
function ShowNormals
global nvert coord scale
global ntria facet
    faces=facet(:,1:3);
    nodes_file=coord; 
    triangles_file=faces;
    node_num=length(nodes_file);
    [nr,nc]=size(triangles_file);
    triangle_num=nr;
%compute the normal vectors without a loop
    points_triangles=[nodes_file(triangles_file,1),nodes_file(triangles_file,2),nodes_file(triangles_file,3)];
    points_one=points_triangles(1:length(points_triangles)/3,:);
    points_two=points_triangles(length(points_triangles)/3+1:length(points_triangles)/3*2,:);
    points_three=points_triangles(length(points_triangles)/3*2+1:length(points_triangles),:);
    vectors_one=points_two-points_one;
    vectors_two=points_three-points_one;
    normal_vectors=cross(vectors_one,vectors_two);
    norms=repmat(sqrt(sum(normal_vectors.^2,2)),[1,3]);
    nnv=normal_vectors./norms*scale;
% center of each facet
    V=1/3*(points_one+points_two+points_three)*scale;
    xc=V(:,1);
    yc=V(:,2);
    zc=V(:,3);    
    quiver3(xc,yc,zc,nnv(:,1),nnv(:,2),nnv(:,3),0.5);  % scale arrows by 0.5
    title(' ')
% end ShowNormals
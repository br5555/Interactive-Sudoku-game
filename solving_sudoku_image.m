function X = solving_sudoku_image(I)
    load prva_dnn.mat
    load druga_dnn.mat
    I = rgb2gray(I);
    I = imrotate(I, -90);
    K = kgauss(5);
    idisp( iconvolve(I, K) );


    S = kcircle(3);
    closed = iclose(I, S);
    clean = iopen(closed, S);
    clean = clean(400: end-400,:);
    img = clean;

    test1 = img( 337:697, 112:483);
    test2 = img(  1:316, 110:463);
    test3 = img( 1:316, 463:902);
    %%
    edges = icanny(isobel(clean));
    h = Hough(edges, 'suppress', 10, 'edgethresh', 0.65);
    lines = h.lines();


    rho_ver= [];

    for i = 1:size(lines,2)
        if(abs(lines(i).theta) > (85.0/90.0)*(pi/2) || abs(lines(i).theta) < -(85.0/90.0)*(pi/2) )
            rho_ver_temp = abs(lines(i).rho_/sin(lines(i).theta_));
            if(rho_ver_temp < size(img,2))
                rho_ver = [rho_ver, rho_ver_temp];
            end
        end
    end

    rho_hor = [];

    for i = 1:size(lines,2)
        if(abs(lines(i).theta) < (5.0/90.0)*(pi/2) || abs(lines(i).theta) > -(5.0/90.0)*(pi/2) )
            rho_hor_temp = abs(lines(i).rho_/cos(lines(i).theta_));
            if(rho_hor_temp < size(img,1))
                rho_hor = [rho_hor, rho_hor_temp];
            end
        end
    end

    rho_hor = sort(rho_hor);
    rho_ver = sort(rho_ver);

    upper_bound_ver = size(clean,2)/8;
    upper_bound_hor = size(clean,1)/8;
    lower_bound_ver = (size(clean,2)/8)*0.3;
    lower_bound_hor = (size(clean,1)/8)*0.3;
    spaces_ver =[]; %zeros(size(rho_hor,2)-1,1);

    for i = 1:size(rho_hor,2)-1

        spaces_ver_temp = rho_hor(i+1)-rho_hor(i);
        if (spaces_ver_temp < upper_bound_ver && spaces_ver_temp > lower_bound_ver)
            spaces_ver = [spaces_ver, spaces_ver_temp];
        end
    end

    spaces_hor =[]; % zeros(size(rho_ver,2)-1,1);

    for i = 1:size(rho_ver,2)-1
        spaces_hor_temp = rho_ver(i+1)-rho_ver(i);
        if(spaces_hor_temp < upper_bound_hor && spaces_hor_temp > lower_bound_hor)
            spaces_hor = [spaces_hor, spaces_hor_temp];
        end
    end


    space_ver =ceil( abs( median(spaces_ver)));
    space_hor =ceil( abs(median(spaces_hor)));

    median_hor = ceil( abs(median(rho_ver)));
    median_ver = ceil( abs(median(rho_hor)));

    points_hor = [median_hor];
    space_hor_temp = median_hor;

    while space_hor_temp -space_hor > 0
        space_hor_temp = space_hor_temp -space_hor;
        points_hor = [points_hor, space_hor_temp];
    end

    space_hor_temp = median_hor;

    while space_hor_temp + space_hor < size(img,2)
        space_hor_temp = space_hor_temp + space_hor;
        points_hor = [points_hor, space_hor_temp];
    end


    points_ver = [median_ver];
    space_ver_temp = median_ver;

    while space_ver_temp -space_ver > 0
        space_ver_temp = space_ver_temp -space_ver;
        points_ver = [points_ver, space_ver_temp];
    end

    space_hor_temp = median_hor;

    while space_ver_temp + space_ver < size(img,1)
        space_ver_temp = space_ver_temp + space_ver;
        points_ver = [points_ver, space_ver_temp];
    end

    points_ver = sort(points_ver);
    points_hor = sort(points_hor);


    if (size(points_ver,1) ~= 10 && size(points_hor,1) ~= 10)
        msg = 'Dear user, please try to take a picture with Sudoku puzzle only.';
        error(msg)
    end

    Ulaz_u_sudoku = zeros(9,9);

    for i = 1 : size(points_ver,1)-1
        for j = 1 : size(points_hor,1)-1
            img_test = (iclose(icanny((imresize(img(points_ver(i):points_ver(i+1) , points_hor(i):points_hor(i+1)),[28 28],'nearest'))),S));
            class_fill_or_not = classify(net_bi  ,img_test);
            if double(class_fill_or_not) == 1
                Ulaz_u_sudoku(i, j) = classify(net_mnist  ,img_test);
            end
        end
    end

    X = sudoku(Ulaz_u_sudoku);
end
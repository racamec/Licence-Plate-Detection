clc;
close all;
clear all;

sb=1; % foto no
x=3;  % her figurde 9 eleman olsun
y=3;

for imageNo = 1:50
    file= "BIM472_Project1_Images\" + int2str(imageNo) +".jpg";
    originalImage= imread(file);  % fotoyu oku arraye çevir
    imgray= rgb2gray(originalImage); % griye çevir
    if sb<= (x*y)  % 9 dan küçükse 
        subplot(x,y,sb); % o pencerede yansıt
    end
    if sb>(x*y) % 9 dan büyükse
        figure;  % yeni pencere aç
        sb=1;
        subplot(x,y,sb);
    end

    sb=sb+1 % bi sonraki fotoya geçecek diğer adımda
    imshow(originalImage); % fotoğrafı göster 
    imgray=imsharpen(imgray); %griye çevirdiğimiz fotoyu keskinleştir
    im=edge(imgray,'Canny');  %canny metodu ile edge(kenar) bulma
    props=regionprops(im,'All');%im deki olabilecek tüm geometrik şekilleri propsta tutuyor

    for i=1:numel(props)   %geometrik şekiller içinde sırayla dön
        boundingBox=props(i).BoundingBox;  %her bir şekli kutucuk (dikdörtgen) içine alıyor
        image=props(i).Image; % kutucukları arrayde tutuyor
        area=props(i).Area; %kutucukların alanı
        extent=props(i).Extent; %kutucukların pixel yoğunluğu
     
        majorAxisLength=props(i).MajorAxisLength; % kutucuğun uzun kenarı
        minorAxisLength=props(i).MinorAxisLength; % kutucuğun kısa kenarı 
       
        % plakaya uygunluğunu kontrol etmemiz gerekiyor
        if (area>100) && (boundingBox(3) > boundingBox(4)*2) && (boundingBox(3) < boundingBox(4)*7) && (extent > 0.03) && (minorAxisLength > boundingBox(4));
           
            plateImage=imcrop(imgray,boundingBox);  %uygun olan şekli al
            plateImage=imbinarize(plateImage); %gri resmi siyah beyaza çevirme
            plateImage=medfilt2(plateImage); %median filtresi ile noise azaltma
            plateImage=~plateImage; %siyahları beyaz beyazları siyah yapma. şekillerin daha çok belli olması için
           
        
            imh=imhist(plateImage); %histogram ile plakanın doğruluğunu kontrol edicez
            plateProps=regionprops(plateImage,'BoundingBox','Area','Image')  %harfleri tanımak için. plaka olup olmadığını
       
            [h,w]=size(plateImage); % plakanın ölçüleri

            numberOfLetter=0;

            for a=1:numel(plateProps) % plaka içindeki şekiller sırayla dönsün
                ow=length(plateProps(a).Image(1,:)); % harf olabilecek geometrik şekillerin enini ve boyunu  bul
                oh=length(plateProps(a).Image(:,1));

                if ow < (h/2) && oh >(h/3)  % eni plakanın boyunun yarısından azsa ya da boyu plakanın boyunun 3 te 1 inden fazlaysa
                    numberOfLetter=numberOfLetter+1
                    

                end
            end
            
            % içinde harf varsa , histogram değerlerine göre 
            if (numberOfLetter>0) && (imh(1) > 500) && (imh(2) > 500) && (imh(1) < 4000) && (imh(2) < 4000)
                % plakadır. kenarları renklendir
                rectangle('Position',[boundingBox(1),boundingBox(2),boundingBox(3),boundingBox(4)],'EdgeColor','g',LineWidth=3);
            
            end
        end
    end

end
%% ============================================================
%  Rectangle plate + fiber angle field TF(x) and fiber streamlines
%  Requirement:
%   1) Rectangular plate
%   2) TF = 2*(TF1-TF0)*abs(x)/LENGTH + TF0 + TFS
%   3) y-axis is symmetry axis => x = 0
%% ============================================================

%% -------------------- User parameters ------------------------
LENGTH = 3;          % total plate length in x direction (same as your LENGTH)
HEIGHT = 5;          % plate height in y direction

TF0 = deg2rad(-45);      % TF0 (radians)  e.g. 0 deg
TF1 = deg2rad(45);     % TF1 (radians)  e.g. 60 deg
TFS = deg2rad(0);      % TFS shift (radians)

% fiber streamline settings
nLines = 13;           % number of fiber streamlines
nSteps = 1500;         % integration steps
ds     = 0.01;          % step size (controls curve resolution)

% sampling for background angle display (quiver)
nx = 25; ny = 15;

%% -------------------- Geometry -------------------------------
xMin = -LENGTH/2; xMax =  LENGTH/2;
yMin = -HEIGHT/2; yMax =  HEIGHT/2;

% TF(x) function (depends only on x, symmetric by abs(x))
TF = @(x) 2*(TF1-TF0).*abs(x)./LENGTH + TF0 + TFS;

%% -------------------- Plot plate boundary --------------------
figure('Color','w'); hold on; axis equal; box on;
xlabel('x'); ylabel('y');
title('Rectangular plate with fiber streamlines (symmetry axis: x = 0)');

% rectangle boundary
plot([xMin xMax xMax xMin xMin],[yMin yMin yMax yMax yMin],'k-','LineWidth',1.5);

% symmetry axis (y-axis, i.e., x=0)
plot([0 0],[yMin yMax],'k--','LineWidth',1.2);

%% -------------------- Angle field arrows (optional) -----------
xg = linspace(xMin,xMax,nx);
yg = linspace(yMin,yMax,ny);
[XG,YG] = meshgrid(xg,yg);

Theta = TF(XG);           % radians
U = cos(Theta);
V = sin(Theta);

% scale arrows to look nice
quiver(XG,YG,U,V,0.5,'Color',[0.75 0.75 0.75]);

%% -------------------- Fiber streamlines -----------------------
% Seed points on symmetry axis x=0, spread in y
ySeeds = linspace(yMin*0.9, yMax*0.9, nLines);

for k = 1:nLines
    % integrate forward and backward from x=0
    x0 = 0; y0 = ySeeds(k);

    [xf,yf] = traceLine(x0,y0, +1, ds, nSteps, TF, xMin,xMax,yMin,yMax);
    [xb,yb] = traceLine(x0,y0, -1, ds, nSteps, TF, xMin,xMax,yMin,yMax);

    % combine backward + forward (avoid duplicate start point)
    xb = flipud(xb); yb = flipud(yb);
    xLine = [xb; xf(2:end)];
    yLine = [yb; yf(2:end)];

    plot(xLine,yLine,'LineWidth',1.6);
end

%% -------------------- Helper: streamline integrator -----------
function [xPath,yPath] = traceLine(x0,y0, dirSign, ds, nSteps, TFfun, xMin,xMax,yMin,yMax)
% dirSign = +1 forward, -1 backward

xPath = zeros(nSteps,1);
yPath = zeros(nSteps,1);

x = x0; y = y0;
xPath(1)=x; yPath(1)=y;

for i = 2:nSteps
    theta = TFfun(x);

    % tangent direction angle w.r.t x-axis
    dx = dirSign * ds * cos(theta);
    dy = dirSign * ds * sin(theta);

    % Euler step
    x = x + dx;
    y = y + dy;

    xPath(i)=x; yPath(i)=y;

    % stop if out of boundary
    if x < xMin || x > xMax || y < yMin || y > yMax
        xPath = xPath(1:i-1);
        yPath = yPath(1:i-1);
        return;
    end
end
end

axis equal
axis off


% % 设置 figure 和坐标轴背景为透明
% set(gcf,'Color','none');   % figure 背景透明
% set(gca,'Color','none');   % axes 背景透明
% 
% % 导出为透明背景 PNG
% exportgraphics(gcf,'fiber_plate.png', ...
%     'BackgroundColor','none', ...
%     'Resolution',300);

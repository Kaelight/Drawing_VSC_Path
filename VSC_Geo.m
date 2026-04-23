%% ============================================================
%  Rectangle plate + fiber angle field TF(x) and fiber streamlines
%  Default: two-edge seeding
%  Manual mode: can choose boundary / midline seeding
%  For midline seeds: extend to both sides automatically
%% ============================================================

clear; clc; close all;

%% -------------------- User parameters ------------------------
LENGTH = 300;          % plate length in x direction
HEIGHT = 300;          % plate height in y direction

TF0 = deg2rad(65);     % radians
TF1 = deg2rad(85);     % radians
TFS = deg2rad(0);      % radians

% streamline settings
nLines = 10;           % number of seed points on each selected boundary
nSteps = 2000;         % integration steps
ds     = 0.5;          % step size

% background angle display
nx = 25;
ny = 25;
showQuiver = true;

%% -------------------- Seeding mode switch --------------------
% seedingMode:
%   'default' -> same as original:
%                +theta from left + bottom
%                -theta from left + top
%   'manual'  -> use user-defined boundaries below
seedingMode = 'manual';

% Allowed names:
%   'left', 'right', 'bottom', 'top', 'midline', 'midline_h'
%
% 'midline'   : vertical centerline x = 0
% 'midline_h' : horizontal centerline y = 0
%
% For 'midline' or 'midline_h', streamlines are traced in BOTH directions.

plusBoundaries  = {'midline_h'};
minusBoundaries = {'midline_h'};

% remove corners / endpoints
removeCorners = true;

%% -------------------- Geometry -------------------------------
xMin = -LENGTH/2;
xMax =  LENGTH/2;
yMin = -HEIGHT/2;
yMax =  HEIGHT/2;

% +theta field
TF = @(x) 2*(TF1-TF0).*abs(x)./LENGTH + TF0 + TFS;
% TF = @(x) (TF1-TF0).*(x+LENGTH/2)./LENGTH + TF0 + TFS;

% -theta field
TF_neg = @(x) -TF(x);

%% -------------------- Plot plate boundary --------------------
figure('Color','w');
hold on;
axis equal;
box on;
xlabel('x');
ylabel('y');
title('Rectangular plate with \pm\theta fiber streamlines');

% rectangle boundary
plot([xMin xMax xMax xMin xMin], ...
     [yMin yMin yMax yMax yMin], ...
     'k-', 'LineWidth', 1.5);

% symmetry axis (y-axis, x=0)
plot([0 0], [yMin yMax], 'k--', 'LineWidth', 1.2);

%% -------------------- Angle field arrows ---------------------
if showQuiver
    xg = linspace(xMin, xMax, nx);
    yg = linspace(yMin, yMax, ny);
    [XG, YG] = meshgrid(xg, yg);

    Theta = TF(XG);
    U = cos(Theta);
    V = sin(Theta);

    quiver(XG, YG, U, V, 0.5, 'Color', [0.75 0.75 0.75]);
end

%% -------------------- Decide seeding boundaries --------------
switch lower(seedingMode)
    case 'default'
        plusBoundaries  = {'left','bottom'};
        minusBoundaries = {'left','top'};
    case 'manual'
        % use user settings
    otherwise
        error('Unknown seedingMode. Use ''default'' or ''manual''.');
end

%% -------------------- Plot +theta fibers ---------------------
for ib = 1:length(plusBoundaries)
    boundaryName = lower(plusBoundaries{ib});
    [xSeeds, ySeeds] = generateSeeds(boundaryName, nLines, xMin, xMax, yMin, yMax, removeCorners);

    for k = 1:length(xSeeds)
        x0 = xSeeds(k);
        y0 = ySeeds(k);

        if isMidline(boundaryName)
            % trace both directions and merge
            [xf, yf] = traceBothDirections(x0, y0, ds, nSteps, TF, xMin, xMax, yMin, yMax);
        else
            [xf, yf] = traceLine(x0, y0, +1, ds, nSteps, TF, xMin, xMax, yMin, yMax);
        end

        if ~isempty(xf)
            plot(xf, yf, 'r', 'LineWidth', 1.4);
        end
    end
end

%% -------------------- Plot -theta fibers ---------------------
for ib = 1:length(minusBoundaries)
    boundaryName = lower(minusBoundaries{ib});
    [xSeeds, ySeeds] = generateSeeds(boundaryName, nLines, xMin, xMax, yMin, yMax, removeCorners);

    for k = 1:length(xSeeds)
        x0 = xSeeds(k);
        y0 = ySeeds(k);

        if isMidline(boundaryName)
            % trace both directions and merge
            [xf, yf] = traceBothDirections(x0, y0, ds, nSteps, TF_neg, xMin, xMax, yMin, yMax);
        else
            [xf, yf] = traceLine(x0, y0, +1, ds, nSteps, TF_neg, xMin, xMax, yMin, yMax);
        end

        if ~isempty(xf)
            plot(xf, yf, 'b', 'LineWidth', 1.4);
        end
    end
end

%% -------------------- Figure settings ------------------------
axis([xMin xMax yMin yMax]);
axis equal;
axis off;

legend({'Boundary','Symmetry axis','Angle field','+\theta fibers','-\theta fibers'}, ...
       'Location','bestoutside');

%% ============================================================
% Helper: identify if the seed source is a midline
%% ============================================================
function tf = isMidline(boundaryName)
    tf = strcmpi(boundaryName,'midline') || strcmpi(boundaryName,'midline_h');
end

%% ============================================================
% Helper: generate seed points on a chosen boundary/midline
%% ============================================================
function [xSeeds, ySeeds] = generateSeeds(boundaryName, nLines, xMin, xMax, yMin, yMax, removeCorners)

    switch lower(boundaryName)
        case 'left'
            if removeCorners
                ySeeds = linspace(yMin, yMax, nLines+2);
                ySeeds = ySeeds(2:end-1);
            else
                ySeeds = linspace(yMin, yMax, nLines);
            end
            xSeeds = xMin * ones(size(ySeeds));

        case 'right'
            if removeCorners
                ySeeds = linspace(yMin, yMax, nLines+2);
                ySeeds = ySeeds(2:end-1);
            else
                ySeeds = linspace(yMin, yMax, nLines);
            end
            xSeeds = xMax * ones(size(ySeeds));

        case 'bottom'
            if removeCorners
                xSeeds = linspace(xMin, xMax, nLines+2);
                xSeeds = xSeeds(2:end-1);
            else
                xSeeds = linspace(xMin, xMax, nLines);
            end
            ySeeds = yMin * ones(size(xSeeds));

        case 'top'
            if removeCorners
                xSeeds = linspace(xMin, xMax, nLines+2);
                xSeeds = xSeeds(2:end-1);
            else
                xSeeds = linspace(xMin, xMax, nLines);
            end
            ySeeds = yMax * ones(size(xSeeds));

        case 'midline'     % vertical centerline x=0
            if removeCorners
                ySeeds = linspace(yMin, yMax, nLines+2);
                ySeeds = ySeeds(2:end-1);
            else
                ySeeds = linspace(yMin, yMax, nLines);
            end
            xSeeds = zeros(size(ySeeds));

        case 'midline_h'   % horizontal centerline y=0
            if removeCorners
                xSeeds = linspace(xMin, xMax, nLines+2);
                xSeeds = xSeeds(2:end-1);
            else
                xSeeds = linspace(xMin, xMax, nLines);
            end
            ySeeds = zeros(size(xSeeds));

        otherwise
            error('Unknown boundary name: %s. Use left/right/top/bottom/midline/midline_h.', boundaryName);
    end
end

%% ============================================================
% Helper: trace from seed in both directions and merge
%% ============================================================
function [xPath, yPath] = traceBothDirections(x0, y0, ds, nSteps, TFfun, xMin, xMax, yMin, yMax)

    [xNeg, yNeg] = traceLine(x0, y0, -1, ds, nSteps, TFfun, xMin, xMax, yMin, yMax);
    [xPos, yPos] = traceLine(x0, y0, +1, ds, nSteps, TFfun, xMin, xMax, yMin, yMax);

    if isempty(xNeg) && isempty(xPos)
        xPath = [];
        yPath = [];
        return;
    end

    if isempty(xNeg)
        xPath = xPos;
        yPath = yPos;
        return;
    end

    if isempty(xPos)
        xPath = xNeg;
        yPath = yNeg;
        return;
    end

    % reverse negative branch and merge, avoid duplicating seed point
    xPath = [flipud(xNeg(:)); xPos(2:end)];
    yPath = [flipud(yNeg(:)); yPos(2:end)];
end

%% ============================================================
% Helper: streamline integrator
%% ============================================================
function [xPath, yPath] = traceLine(x0, y0, dirSign, ds, nSteps, TFfun, xMin, xMax, yMin, yMax)
% dirSign = +1 forward, -1 backward

    xPath = zeros(nSteps,1);
    yPath = zeros(nSteps,1);

    x = x0;
    y = y0;

    xPath(1) = x;
    yPath(1) = y;

    for i = 2:nSteps
        theta = TFfun(x);

        dx = dirSign * ds * cos(theta);
        dy = dirSign * ds * sin(theta);

        x = x + dx;
        y = y + dy;

        xPath(i) = x;
        yPath(i) = y;

        if x < xMin || x > xMax || y < yMin || y > yMax
            xPath = xPath(1:i-1);
            yPath = yPath(1:i-1);
            return;
        end
    end
end
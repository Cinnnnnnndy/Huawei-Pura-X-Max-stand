// ============================================================
// 华为 Pura X Max 桌面支架 · 中脊一体款（75°）
// 单位：mm    OpenSCAD 2021+
// © 2026 Cinnnnnnndy · CC BY-NC-SA 4.0 · https://github.com/Cinnnnnnndy/Huawei-Pura-X-Max-stand
// 华为、HUAWEI、Pura 是华为技术有限公司的商标，本项目与华为无关联
//
// 机身（官网）：高 120；展开宽 166.5 / 厚 5.2；折叠宽 85 / 厚 11.2；229 g
//   折叠竖放 85×120   折叠横放 120×85   展开横放 166.5×120   展开竖放 120×166.5
//
// 摄像头避让：
//   后摄是一块横向圆角矩形模组，在机背上沿附近，明显凸起（官方厚度不含模组）。
//   靠背只做一条居中的窄脊（宽 40，贴合高度 68），模组在任何摆放下都落在脊外：
//     折叠竖放 / 展开横放：模组在手机上部，高于脊顶
//     折叠横放 / 展开竖放：模组转到一侧，离中心 ≥ 24 mm，在脊旁边悬空
//   模组位置按公开描述估算，cam_* 参数可按实机改。
//
// 防滑：
//   - 托底与靠背成 90°，手机自己落进根部，不会往前溜
//   - 托槽深 18，按市面常见手机壳放得下来定：
//       折叠 11.2 + 每面壳 ≤2.6（总厚 ≤16.5）完全不碰；16.5–18 会贴到前侧 R1.5 内圆角，仍放得进
//       覆盖：超薄壳、普通 TPU/PC 壳、皮革壳、带铰链保护的壳、四角气囊壳
//       不覆盖：带支架/指环/卡包的加厚壳、重型三防壳
//     展开 5.2 + 壳 也同样贴靠背，托底上坡让手机自己回到根部，角度不变
//   - 前沿高 4.5：托底往前是上坡，手机自己回到根部，前沿只防碰；这个高度在俯视 ≥20° 时不挡屏幕
//   - 脊面两条、托底一条 0.8 mm 浅槽，贴硅胶防滑条（或打印 part="pads" 的 TPU 条）
//   - 底面 4 个脚垫位
//
// 充电：托底中间有插头坑，配 90° 弯头 USB-C 线，线从底面槽里走、后沿出
//
// 打印：底面朝下，无需支撑。PETG/PLA，0.2 层高，4 圈墙，20% 填充。
//   导出：openscad -D 'part="stand"' -o stand.stl pura_x_max_stand.scad
// ============================================================

/* [显示] */
part       = "assembled"; // [assembled, stand, pads]
show_phone = "none";      // [none, fold_portrait, fold_landscape, open_landscape, open_portrait]

/* [角度与托槽] */
angle  = 75;      // 靠背与桌面夹角
gap    = 18;      // 托槽深（垂直靠背）。折叠带壳总厚 ≤ gap - 1.5 不碰前侧内圆角
lip_h  = 4.5;     // 前沿高（沿靠背方向）。6 会在低视角挡住屏幕底边约 2 mm，4.5 在俯视 ≥20° 时不挡
lip_t  = 5;
zc     = 10;      // 托槽根部离桌面高度

/* [中脊] */
spine_w = 40;
ts      = 7;      // 脊厚
s_top   = 68;     // 脊面贴合长度（从托底算）
top_r   = 13;     // 脊顶圆角

/* [后鳍] */
fin_w   = 16;
fin_s   = 52;     // 鳍接到脊背的高度（沿脊）
fin_y   = 96;     // 鳍落到底板的位置

/* [底座] */
W       = 110;
Lbase   = 120;
tb      = 5;
corner  = 14;
fillet  = 2;

/* [防滑与底部] */
pad_d   = 0.8;    // 防滑条凹槽深
pad_w   = 8;
notch_w = 13;     // 托底中间插头坑（折叠竖放充电口位置，用 90° 弯头线）
cable_d = 5;      // 底面走线槽宽
coin_d  = 25.5;   // 一元硬币配重位
coin_h  = 2.0;
foot_d  = 10.5;
foot_h  = 1.2;

/* [摄像头模组估计（折叠态、看机背、以手机左下为原点）] */
cam_x0 = 11.5;  cam_x1 = 73.5;
cam_y0 = 84;    cam_y1 = 112;
cam_h  = 3.5;
case_t = 1.2;    // 演示用壳厚（每面）；检查时用 0 和 2.6 两种极端

$fn = 64;
eps = 0.01;

// ---------- 坐标 ----------
// 局部系：x 横向，s 沿脊面向上，n 垂直脊面向前（手机一侧为 n ≥ 0），原点 = 托槽根部
b  = [cos(angle),  sin(angle)];
f  = [-sin(angle), cos(angle)];
yc = (gap + lip_t) * sin(angle);
C  = [yc, zc];
function W2(s, n) = C + s * b + n * f;   // 局部 (s, n) → 世界 (y, z)
hw = spine_w / 2;

module to_world() {
    multmatrix([[1, 0,    0,    0],
                [0, b[0], f[0], C[0]],
                [0, b[1], f[1], C[1]],
                [0, 0,    0,    1]]) children();
}
module xslab(x0, x1) {      // 把 YZ 平面的 2D 轮廓沿 X 拉伸
    translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0) children();
}
module footprint() {
    offset(r = corner) offset(delta = -corner) translate([-W/2, 0]) square([W, Lbase]);
}

// ---------- 底板 ----------
module plate() {
    n = 6;
    hull() {
        linear_extrude(eps) offset(delta = -0.5) footprint();
        translate([0, 0, 0.5]) linear_extrude(eps) footprint();
        for (i = [0 : n]) let(a = 90 * i / n)
            translate([0, 0, tb - fillet + fillet * sin(a)])
                linear_extrude(eps) offset(delta = -fillet * (1 - cos(a))) footprint();
    }
}

// ---------- 前沿 + 托底（整条，不开齿） ----------
module front_band() {
    P_back = W2(0, -ts);
    D = P_back - (P_back[1] / b[1]) * b;      // 脊背面延长到桌面
    intersection() {
        xslab(-W/2, W/2)
            offset(r = -1.5) offset(r = 1.5)
            offset(r = 2) offset(delta = -2)
                polygon([[W2(0, gap + lip_t)[0], 0],
                         W2(0, gap + lip_t), W2(lip_h, gap + lip_t), W2(lip_h, gap),
                         W2(0, gap), C, P_back, D]);
        linear_extrude(50) footprint();
    }
}

// ---------- 中脊 ----------
module spine() {
    k = 1.5;
    to_world() minkowski() {
        translate([0, 0, -ts + k]) linear_extrude(ts - 2 * k)
            hull() {
                translate([-(hw - k), -12]) square([2 * (hw - k), 1]);
                for (sx = [-1, 1]) translate([sx * (hw - k - top_r), s_top - k - top_r]) circle(top_r);
            }
        sphere(k, $fn = 16);
    }
}

// ---------- 后鳍：脊背到底板的一道弧 ----------
function bez(p0, p1, p2, t) = (1 - t) * (1 - t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2;
module fin() {
    k = 1.5;
    Q  = W2(fin_s, -ts + 0.5);                       // 鳍上端（略吃进脊里）
    Pc = W2(0, -ts) - ((W2(0, -ts)[1] - tb) / b[1]) * b; // 脊背线与底板面交点
    R  = [fin_y, tb - 0.5];
    arc = [for (i = [0 : 24]) bez(R, Pc, Q, i / 24)];
    minkowski() {
        xslab(-fin_w/2 + k, fin_w/2 - k)
            offset(delta = -k)
                polygon(concat([[W2(0, -ts)[0] - 4, 0.5], [fin_y + 2, 0.5]], arc,
                               [W2(0, -ts + 0.5)]));
        sphere(k, $fn = 16);
    }
}

// ---------- 防滑条位置（局部系） ----------
pad_spine_x = [-11, 11];
pad_spine_s = [10, s_top - 16];
pad_floor_l  = 84;
pad_floor_n0 = 2;
pad_floor_n1 = gap - 4;
module pad_shapes(h) {
    // 脊面两条竖条
    for (x = pad_spine_x)
        to_world() translate([0, 0, -h + eps])
            linear_extrude(h) hull() for (s = pad_spine_s) translate([x, s]) circle(d = pad_w);
    // 托底一条横条（手机下沿压在上面）
    to_world() translate([-pad_floor_l/2, -h, pad_floor_n0]) cube([pad_floor_l, h + eps, pad_floor_n1 - pad_floor_n0]);
}

module stand() {
    difference() {
        intersection() {
            union() { plate(); front_band(); spine(); fin(); }
            translate([-W, -1, 0]) cube([2 * W, Lbase + 2, 200]);
        }
        pad_shapes(pad_d);
        // 隐藏走线：托底中间一个插头坑 → 底面一条线槽 → 从后沿中间出线，前沿保持完整
        translate([0, yc - notch_w/2 - 0.2, 1]) cylinder(d = notch_w, h = 60);
        translate([-cable_d/2, W2(0, gap)[0] + 6, -1]) cube([cable_d, Lbase, cable_d / 2 + 1 + 1.5]);
        for (x = [-30, 30], y = [46, 92])
            translate([x, y, -eps]) cylinder(d = coin_d, h = coin_h + eps);
        for (x = [-W/2 + 11, W/2 - 11], y = [11, Lbase - 11])
            translate([x, y, -eps]) cylinder(d = foot_d, h = foot_h + eps);
    }
}

// TPU 防滑条：比凹槽高出 0.5
// 托底那条被中间线槽切成两段，所以打两段
module pads() {
    for (i = [0, 1])
        translate([i * (pad_w + 4), 0, 0])
            linear_extrude(pad_d + 0.5) hull() for (s = pad_spine_s) translate([0, s]) circle(d = pad_w - 0.3);
    seg = (pad_floor_l - notch_w) / 2 - 0.6;
    for (i = [0, 1])
        translate([30 + i * (pad_floor_n1 - pad_floor_n0 + 4), 0, 0])
            linear_extrude(pad_d + 0.5) square([pad_floor_n1 - pad_floor_n0 - 0.3, seg]);
}

// ---------- 演示手机（局部系；cam = [x0, x1, s0, s1]，相对手机左下角） ----------
module phone(w, h, t, cam) {
    to_world() translate([-w/2, 0.2, 0.2]) {
        color("#26262a") cube([w, h, t]);
        color("#3d5a80") translate([2.5, 3, t - eps]) cube([w - 5, h - 6, 0.3]);
        color("#55555c") translate([cam[0], cam[2], -cam_h])
            linear_extrude(cam_h + eps) offset(r = 6) offset(delta = -6)
                square([cam[1] - cam[0], cam[3] - cam[2]]);
    }
}
ft = 11.2 + 2 * case_t;
ot = 5.2 + case_t;
module phones() {
    if (show_phone == "fold_portrait")  phone(85, 120, ft, [cam_x0, cam_x1, cam_y0, cam_y1]);
    if (show_phone == "fold_landscape") phone(120, 85, ft, [120 - cam_y1, 120 - cam_y0, cam_x0, cam_x1]);
    if (show_phone == "open_landscape") phone(166.5, 120, ot, [81.5 + cam_x0, 81.5 + cam_x1, cam_y0, cam_y1]);
    if (show_phone == "open_portrait")  phone(120, 166.5, ot, [120 - cam_y1, 120 - cam_y0, 81.5 + cam_x0, 81.5 + cam_x1]);
}

// 视线示意：从前方以不同俯角擦过前沿上角，落到屏幕上的位置
show_sight = false;
sight_deg  = [20, 30, 45];
module sight_lines(t) {
    for (e = sight_deg) {
        P = W2(lip_h - 0.6, gap + lip_t - 0.6);
        k = e + angle;
        lam = (gap + lip_t - 0.6 - t) / sin(k);
        d = [cos(e), -sin(e)];
        A0 = P - 70 * d; A1 = P + lam * d;
        color("#d1495b") hull() for (q = [A0, A1]) translate([-W/2 - 1, q[0], q[1]]) sphere(0.35, $fn = 8);
    }
}

if (part == "assembled") {
    color("#ece8e1") stand(); phones();
    if (show_sight) sight_lines(show_phone == "fold_portrait" || show_phone == "fold_landscape" ? ft : ot);
}
if (part == "stand")     stand();
if (part == "pads")      pads();

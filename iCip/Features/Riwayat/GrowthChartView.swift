//
//  GrowthChartView.swift
//  iCipApp
//
//  WHO-standard growth chart using Swift Charts.
//  Displays Z-score bands, reference lines, and baby's trajectory.
//

import SwiftUI
import Charts

// MARK: - Growth Chart View
struct GrowthChartView: View {
    
    @ObservedObject var viewModel: RiwayatViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(AppColors.greenMain)
                Text(viewModel.selectedIndicator.title)
                    .font(AppFonts.heading3())
                    .foregroundColor(AppColors.textDark)
            }
            .padding(.horizontal, 24)
            
            let dataPoints = viewModel.chartDataPoints(for: viewModel.selectedIndicator)
            let bands = viewModel.bandAreas(for: viewModel.selectedIndicator)
            let refLines = viewModel.referenceLines(for: viewModel.selectedIndicator)
            
            if dataPoints.isEmpty {
                emptyChartState
            } else {
                chartView(dataPoints: dataPoints, bands: bands, refLines: refLines)
            }
            
            // Z-score legend
            legendView
        }
    }
    
    // MARK: - Chart View (broken up for compiler performance)
    
    private func chartView(
        dataPoints: [RiwayatViewModel.ChartDataPoint],
        bands: [RiwayatViewModel.BandArea],
        refLines: [RiwayatViewModel.ReferenceLine]
    ) -> some View {
        Chart {
            bandMarks(bands: bands)
            referenceLineMarks(refLines: refLines)
            babyLineMarks(dataPoints: dataPoints)
            dataPointMarks(dataPoints: dataPoints)
        }
        .chartXAxisLabel(viewModel.selectedIndicator.xAxisLabel)
        .chartYAxisLabel(viewModel.selectedIndicator.yAxisLabel)
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                AxisValueLabel()
                    .font(.system(size: 9))
                    .foregroundStyle(AppColors.textSubtleGray)
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                AxisValueLabel()
                    .font(.system(size: 9))
                    .foregroundStyle(AppColors.textSubtleGray)
            }
        }
        .frame(height: 240)
        .padding(16)
        .background(AppColors.cardWhite)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 24)
        .animation(.easeInOut(duration: 0.3), value: viewModel.selectedIndicator)
    }
    
    @ChartContentBuilder
    private func bandMarks(bands: [RiwayatViewModel.BandArea]) -> some ChartContent {
        ForEach(bands) { band in
            ForEach(Array(band.lowerPoints.indices), id: \.self) { i in
                if i < band.upperPoints.count {
                    AreaMark(
                        x: .value("X", band.lowerPoints[i].x),
                        yStart: .value("Lower", band.lowerPoints[i].y),
                        yEnd: .value("Upper", band.upperPoints[i].y)
                    )
                    .foregroundStyle(band.color)
                    .interpolationMethod(.catmullRom)
                }
            }
        }
    }
    
    @ChartContentBuilder
    private func referenceLineMarks(refLines: [RiwayatViewModel.ReferenceLine]) -> some ChartContent {
        ForEach(refLines) { line in
            singleReferenceLine(line: line)
        }
    }
    
    @ChartContentBuilder
    private func singleReferenceLine(line: RiwayatViewModel.ReferenceLine) -> some ChartContent {
        let lineColor: Color = line.zScore == 0 ? Color.gray.opacity(0.6) : Color.gray.opacity(0.25)
        let lineWidth: CGFloat = line.zScore == 0 ? 1.5 : 0.8
        let dashPattern: [CGFloat] = line.zScore == 0 ? [] : [4, 3]
        ForEach(Array(line.points.indices), id: \.self) { i in
            LineMark(
                x: .value("X", line.points[i].x),
                y: .value("Y", line.points[i].y),
                series: .value("Z", "ref-\(line.zScore)")
            )
            .foregroundStyle(lineColor)
            .lineStyle(StrokeStyle(lineWidth: lineWidth, dash: dashPattern))
            .interpolationMethod(.catmullRom)
        }
    }
    
    @ChartContentBuilder
    private func babyLineMarks(dataPoints: [RiwayatViewModel.ChartDataPoint]) -> some ChartContent {
        ForEach(dataPoints) { point in
            LineMark(
                x: .value("X", point.x),
                y: .value("Y", point.y),
                series: .value("Z", "baby")
            )
            .foregroundStyle(AppColors.orangeMain)
            .lineStyle(StrokeStyle(lineWidth: 2.5))
            .interpolationMethod(.catmullRom)
        }
    }
    
    @ChartContentBuilder
    private func dataPointMarks(dataPoints: [RiwayatViewModel.ChartDataPoint]) -> some ChartContent {
        ForEach(dataPoints) { point in
            PointMark(
                x: .value("X", point.x),
                y: .value("Y", point.y)
            )
            .foregroundStyle(point.isLatest ? AppColors.orangeMain : AppColors.orangeLight)
            .symbolSize(point.isLatest ? 80 : 30)
            .annotation(position: .top, spacing: 4) {
                if point.isLatest {
                    latestPointLabel(value: point.y)
                }
            }
        }
    }
    
    private func latestPointLabel(value: Double) -> some View {
        Text(String(format: "%.1f", value))
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundColor(AppColors.orangeMain)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(AppColors.orangeTint)
            .cornerRadius(6)
    }
    
    // MARK: - Empty State
    private var emptyChartState: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.surfaceGray)
                .frame(height: 200)
            
            VStack(spacing: 10) {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 34))
                    .foregroundColor(AppColors.textSubtleGray)
                Text("Belum ada data pertumbuhan")
                    .font(AppFonts.bodyRegular())
                    .foregroundColor(AppColors.textMidGray)
                Text("Tambah data untuk melihat grafik")
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.textSubtleGray)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Legend
    private var legendView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                legendItem(color: Color(hex: "#E53935").opacity(0.4), label: "< -3")
                legendItem(color: Color(hex: "#FF9800").opacity(0.4), label: "-3 ~ -2")
                legendItem(color: Color(hex: "#FFB300").opacity(0.4), label: "-2 ~ -1")
                legendItem(color: Color(hex: "#4CAF50").opacity(0.4), label: "Normal")
                legendItem(color: Color(hex: "#1E88E5").opacity(0.4), label: "+1 ~ +2")
                legendItem(color: Color(hex: "#7B1FA2").opacity(0.4), label: "> +2")
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(AppColors.textSubtleGray)
        }
    }
}

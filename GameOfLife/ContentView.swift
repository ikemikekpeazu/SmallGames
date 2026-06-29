//
//  ContentView.swift
//  GameOfLife
//
//  Created by Ikem Ikekpeazu on 6/29/26.
//

import SwiftUI
import Combine


struct ContentView: View {
    @State var states: [[Bool]] = Array(repeating: Array(repeating: false, count: 20), count: 20)
    @State var nextStates: [[Bool]] = Array(repeating: Array(repeating: false, count: 20), count: 20)
    
    @State var isRunning: Bool = false
    
    @State var timer = Timer.publish(every: 0.5, on: .main, in: .common)
    @State var timerSubscription: Cancellable? = nil
    let directions = [(1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (-1, -1), (1, -1), (-1, 1)]
    
    var body: some View {
        Grid() {
            ForEach(states.indices, id: \.self) { row in
                GridRow {
                    ForEach(states[row].indices, id: \.self) { column in
                        Rectangle()
                            .fill(states[row][column] ? Color.blue : Color.gray)
                            .onTapGesture {
                                states[row][column].toggle()
                            }
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            stepLogicV2()
        }
        .onChange(of: isRunning, { _ , running in
            if running {
                startTimer()
            } else {
                stopTimer()
            }
        })
        .padding()
        Button("Clear") {
            for row in states.indices {
                for column in states[row].indices {
                    states[row][column] = false
                    nextStates[row][column] = false
                }
            }
        }
        Button("Next") {
            stepLogicV2()
        }
        .disabled(isRunning)
        Button(isRunning ? "Stop" : "Start") {
            isRunning.toggle()
        }
    }
    private func startTimer() {
        timer = Timer.publish(every: 0.5, on: .main, in: .common)
        timerSubscription = timer.connect()
    }
    private func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }
}

#Preview {
    ContentView()
}



extension ContentView {
    private func stepLogicV1() {
        for row in states.indices {
            for column in states[row].indices {
                var neighbors = 0
                if column != 19 {
                    if states[row][column + 1] {
                        neighbors += 1
                    }
                }
                if column != 0 {
                    if states[row][column - 1] {
                        neighbors += 1
                    }
                }
                if row != 19 {
                    if states[row + 1][column] {
                        neighbors += 1
                    }
                }
                if row != 0 {
                    if states[row - 1][column] {
                        neighbors += 1
                    }
                }
                if row != 19 && column != 19 {
                    if states[row + 1][column + 1] {
                        neighbors += 1
                    }
                }
                if row != 0 && column != 0 {
                    if states[row - 1][column - 1] {
                        neighbors += 1
                    }
                }
                if row != 19 && column != 0 {
                    if states[row + 1][column - 1] {
                        neighbors += 1
                    }
                }
                if row != 0 && column != 19 {
                    if states[row - 1][column + 1] {
                        neighbors += 1
                    }
                }
                
                if states[row][column] && neighbors < 2 {
                    nextStates[row][column] = false
                } else if states[row][column] && neighbors > 3 {
                    nextStates[row][column] = false
                }
                if !states[row][column] && neighbors == 3 {
                    nextStates[row][column] = true
                }
            }
        }
        for row in states.indices {
            for column in states[row].indices {
                states[row][column] = nextStates[row][column]
            }
        }
    }
    private func stepLogicV2() {
        for row in states.indices {
            for column in states[row].indices {
                var neighbors = 0
                for (dr, dc) in directions {
                    let newRow = row + dr
                    let newColumn = column + dc
                    
                    if newRow >= 0 && newRow <= 19 && newColumn >= 0 && newColumn <= 19 && states[newRow][newColumn] {
                        neighbors += 1
                    }
                }
                
                if states[row][column] && neighbors < 2 {
                    nextStates[row][column] = false
                } else if states[row][column] && neighbors > 3 {
                    nextStates[row][column] = false
                }
                if !states[row][column] && neighbors == 3 {
                    nextStates[row][column] = true
                }
            }
        }
        
        states = nextStates
        
    }
}

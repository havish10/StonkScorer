//
//  SavedScoresListView.swift
//  StonkScorer
//
//  Created by Alexandru Turcanu on 05/02/2020.
//  Copyright © 2020 CodingBytes. All rights reserved.
//

import SwiftUI

struct SavedScoresListView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: SkystoneScore.entity(), sortDescriptors: []) var scores: FetchedResults<SkystoneScore>

    @State private var showingDeleteAllAlert = false

    var body: some View {
        List {
            ForEach(scores, id: \.self) { score in
                NavigationLink(destination: SavedScoreDetailView(score: score).environment(\.managedObjectContext, self.moc)) {
                    SavedScoreRow(score: score)
                        .animation(.linear)
                }
            }
            .onDelete(perform: deleteScores)
        }
        .animation(.linear)
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Saved Scores")
        .navigationBarItems(trailing:
            HStack {
                Button(action: {
                    self.shareScores()
                }, label: {
                    Image(systemName: "square.and.arrow.up")
                        .navigationBarStyle()
                })

                Button(action: {
                    self.showingDeleteAllAlert.toggle()
                }, label: {
                    Image(systemName: "trash")
                        .navigationBarStyle()
                })
                    .alert(isPresented: $showingDeleteAllAlert) {
                        Alert(
                            title: Text("Delete all scores?"),
                            message: Text("Are you sure you want to delete all saved scores?"),
                            primaryButton: .cancel(),
                            secondaryButton: .destructive(Text("Delete"), action: {
                                //TODO: a cleaner solution should exist, but for now it gets the job done
                                for score in self.scores {
                                    score.delete(in: self.moc)
                                }
                            }))
                }
            }
        )
    }

    func deleteScores(at offsets: IndexSet) {
        for offset in offsets {
            scores[offset].delete(in: moc)
        }
    }

    func shareScores() {
        let header = """
        Team Number, Match Number, Alliance, Auto - Foundation Repositioned, \
        Auto - Skystone Bonuses, Auto - Stones Delivered, Auto - Stones Placed, Auto - Nr of Navigations, \
        TeleOp - Stones Delivered, TeleOp - Stones Placed, TeleOp - Skyscraper Height, \
        EndGame - Nr of Capstone Bonuses, EndGame - Capstone 1 Level, EndGame - Capstone 2 Level, EndGame - Foundation Moved, EndGame - Nr of Parking, \
        Comments\n
        """

        var exportString = header

        for score in scores {
            exportString.append("""
                \(score.teamNumber ?? ""), \(score.matchNumber ?? ""), \(score.allianceColor == 0 ? "Blue" : "Red"), \
                \(score.foundationRepositioned), \(score.numberOfSkystoneBonuses), \(score.autoStonesDelivered), \(score.autoStonesPlaced), \(score.numberOfNavigations), \
                \(score.teleOpStonesPlaced), \(score.teleOpStonesDelivered), \(score.skyscraperHeight), \
                \(score.capstoneBonuses), \(score.firstCapstoneLevel), \(score.secondCapstoneLevel), \(score.foundationMoved), \(score.numberOfParkings), \
                \(score.comments ?? "")\n
                """)
        }


        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let csvFile = documentsDirectory.appendingPathComponent("FTCScorer - \(UIDevice.current.name).csv")

        do {
            try exportString.write(to: csvFile, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to create file. Error: \(error.localizedDescription)")
        }

        csvFile.share()
    }
}

struct SavedScoresView_Previews: PreviewProvider {
    static var previews: some View {
        SavedScoresListView()
    }
}

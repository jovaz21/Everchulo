//
//  NoteDetailViewController+ActionsMenu.swift
//  Everchulo
//
//  Created by ATEmobile on 10/4/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import AVFoundation
import UIKit

// MARK: - View Stuff
extension NoteDetailViewController {
    
    // Alarm Menu Action
    @objc func displayAlarmMenuAction() { DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
        
        /* menu */
        let actionSheetMenu = makeActionSheetMenu(title: nil, message: nil, items:
            (
                title:      i18NString("NoteDetailsViewController.alarm.setAlarmMsg"),
                style:      .default,
                image:      nil,
                hidden:     false,
                handler:    { (alertAction) in
                    
                    /* Date Picker */
                    let actionSheet = makeActionSheetDatePicker(title: i18NString("NoteDetailsViewController.alarm.setAlarmTitle"), message: nil, doneAction:
                        (
                            title:      i18NString("es.atenet.app.Done"),
                            handler:    {(action, datePicker) in
                                self.note!.setAlarm(datePicker.date)
                        }
                        ), cancelAction:
                        (
                            title:      i18NString("es.atenet.app.Cancel"),
                            handler:    {(action, datePicker) in
                        }
                        ), initialValue: Date(timeIntervalSince1970: self.note!.alarmTimestamp)
                    )
                    self.present(actionSheet, animated: true, completion: nil)
                }
            ),
            (
                title:      i18NString("NoteDetailsViewController.alarm.deleteAlarmMsg"),
                style:      .default,
                image:      nil,
                hidden:     false,
                handler:    { (alertAction) in
                                                        
                    /* set */
                    self.note!.resetAlarm()
                                                        
                    // Paint UIView
                    self.paintUIView()
                }
            ),
            (
                title:      i18NString("es.atenet.app.Cancel"),
                style:      .cancel,
                image:      nil,
                hidden:     false,
                handler:    nil
            )
        )
        
        /* present */
        self.present(actionSheetMenu, animated: true, completion: nil)
        
    })}
    
    // Infos Menu Action
    @objc func displayInfosAction() {
    }
    
    // Note Menu Action
    @objc func displayNoteMenuAction() { DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
        
        /* menu */
        let actionSheetMenu = makeActionSheetMenu(title: nil, message: nil, items:
            (
                title:      i18NString("NoteDetailsViewController.menu.setAlarmMsg"),
                style:      .default,
                image:      nil,
                hidden:     (self.note!.alarmTimestamp > 0),
                handler:    { (alertAction) in
                    let nextFiveMinuteIntervalDate = Date().rounded(minutes: 5, rounding: .ceil)
                    print(nextFiveMinuteIntervalDate)
                    
                    /* Date Picker */
                    let actionSheet = makeActionSheetDatePicker(title: i18NString("NoteDetailsViewController.alarm.setAlarmTitle"), message: nil, doneAction:
                        (
                            title:      i18NString("es.atenet.app.Done"),
                            handler:    {(action, datePicker) in
                                
                                /* set */
                                self.note!.setAlarm(datePicker.date)
                                
                                // Paint UIView
                                self.paintUIView()
                        }
                        ), cancelAction:
                        (
                            title:      i18NString("es.atenet.app.Cancel"),
                            handler:    {(action, datePicker) in
                        }
                        ), initialValue: nextFiveMinuteIntervalDate
                    )
                    self.present(actionSheet, animated: true, completion: nil)
            }
            ),
            (
                title:      i18NString("NoteDetailsViewController.menu.duplicateMsg"),
                style:      .default,
                image:      nil,
                hidden:     false,
                handler:    { (alertAction) in
                                                        
                    /* duplicate */
                    self.note = self.noteController?.duplicate(fromNote: self.note!)
                                                        
                    // Paint UIView
                    self.paintUIView()
               }
            ),
            (
               title:      i18NString("NoteDetailsViewController.menu.moveMsg"),
               style:      .default,
               image:      nil,
               hidden:     false,
               handler:    { (alertAction) in
                    self.onSelectNotebook()
               }
            ),
            (
               title:      i18NString("NoteDetailsViewController.menu.moveToTrashMsg"),
               style:      .destructive,
               image:      nil,
               hidden:     false,
               handler:    { (alertAction) in
                                                        
                    /* trash */
                    self.noteController?.moveToTrash(note: self.note!)
                                                        
                    /* */
                    self.navigationController?.popViewController(animated: true)
               }
            ),
            (
               title:      i18NString("es.atenet.app.Cancel"),
               style:      .cancel,
               image:      nil,
               hidden:     false,
               handler:    nil
            )
        )
        
        /* present */
        self.present(actionSheetMenu, animated: true, completion: nil)
    })}
}

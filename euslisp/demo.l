#!/usr/bin/env roseus

;; load package
(ros::load-ros-package "naoqi_bridge_msgs")
(ros::load-ros-package "naoeus")
(ros::load-ros-package "roseus")

;; load files
(require :nao-interface "package://naoeus/nao-interface.l")
(nao-init)

(ros::roseus "reception-demo")

(defparameter *last_time_robot_said_words* (ros::time-now))
(defparameter *last_people_id_robot_said_words* 0)
(defparameter *speak-flag* t)

(defun init ()
  ;; disable life
  (if (not (string= (send *ri* :get-life) "disabled"))
      (send *ri* :disable-life)
    )
  ;; servo on
  (send *ri* :servo-on)

  ;; enable life
  (send *ri* :enable-life)

  ;; set language "Japanese"
  (send *ri* :set-language "Japanese")

  ;; set volume as 40
  (send *ri* :set-master-volume 40)
  )

(defun people-perception-cb (msg)
  ;; condition
  ;; if face is deteced
  (if (and (> (send (ros::time- (ros::time-now) *last_time_robot_said_words*) :to-sec) 5) (not (eq (send msg :people_detected :people_id) *last_people_id_robot_said_words*)))
      (progn
	(setq *last_time_robot_said_words* (ros::time-now))
	(setq *last_people_id_robot_said_words* (send msg :people_detected :people_id))
	(setq *speak-flag* t)
	))

  (if *speak-flag*
      (progn
	(setq *speak-flag* nil)
	(send *ri* :speak-action "\\rspd=90\\こんにちは！\\pau=1000\\出席を\\pau=200\\書いてください\\pau=1000\\今日の授業も，よろしくお願いしますッ\\rspd=100\\")
	)))

(ros::subscribe "people_perception" naoqi_bridge_msgs::PeoplePerception #'people-perception-cb)

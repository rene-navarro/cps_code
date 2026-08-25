-- ============================================================
-- SISTEMA INTELIGENTE DE CONTROL DE TRÁFICO
-- Campus Universidad de Sonora
-- PostgreSQL
-- ============================================================

-- ============================================================
-- 1. TABLAS BASE EXISTENTES
-- ============================================================

CREATE TABLE locations (
    location_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) DEFAULT 'Hermosillo',
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6)
);

CREATE TABLE devices (
    device_id VARCHAR(50) PRIMARY KEY,
    device_type VARCHAR(50) NOT NULL,
    location_id INT,
    installed_date DATE,
    status VARCHAR(20) DEFAULT 'ACTIVE',

    CONSTRAINT fk_device_location
        FOREIGN KEY (location_id)
        REFERENCES locations(location_id),

    CONSTRAINT chk_device_status
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'MAINTENANCE', 'FAILED'))
);

CREATE TABLE sensor_readings (
    reading_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    device_id VARCHAR(50) NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    value DOUBLE PRECISION NOT NULL,

    CONSTRAINT fk_reading_device
        FOREIGN KEY (device_id)
        REFERENCES devices(device_id)
);


-- ============================================================
-- 2. MÉTRICAS DE SENSORES
-- ============================================================

CREATE TABLE sensor_metrics (
    metric_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    metric_name VARCHAR(50) NOT NULL UNIQUE,
    unit VARCHAR(30),
    description VARCHAR(200)
);

ALTER TABLE sensor_readings
ADD COLUMN metric_id INT;

ALTER TABLE sensor_readings
ADD CONSTRAINT fk_reading_metric
FOREIGN KEY (metric_id)
REFERENCES sensor_metrics(metric_id);


-- ============================================================
-- 3. RED VIAL
-- ============================================================

CREATE TABLE intersections (
    intersection_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    location_id INT NOT NULL,
    intersection_name VARCHAR(100) NOT NULL,
    intersection_type VARCHAR(30),

    CONSTRAINT fk_intersection_location
        FOREIGN KEY (location_id)
        REFERENCES locations(location_id)
);

CREATE TABLE road_segments (
    segment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    segment_name VARCHAR(100) NOT NULL,

    start_location_id INT NOT NULL,
    end_location_id INT NOT NULL,

    length_m NUMERIC(10,2),
    speed_limit_kmh NUMERIC(5,2),
    direction VARCHAR(20),

    CONSTRAINT fk_segment_start
        FOREIGN KEY (start_location_id)
        REFERENCES locations(location_id),

    CONSTRAINT fk_segment_end
        FOREIGN KEY (end_location_id)
        REFERENCES locations(location_id),

    CONSTRAINT chk_segment_length
        CHECK (length_m IS NULL OR length_m > 0),

    CONSTRAINT chk_speed_limit
        CHECK (speed_limit_kmh IS NULL OR speed_limit_kmh > 0),

    CONSTRAINT chk_segment_locations
        CHECK (start_location_id <> end_location_id)
);

CREATE TABLE lanes (
    lane_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    segment_id INT NOT NULL,
    lane_number SMALLINT NOT NULL,
    direction VARCHAR(20),
    lane_type VARCHAR(30) DEFAULT 'GENERAL',

    CONSTRAINT fk_lane_segment
        FOREIGN KEY (segment_id)
        REFERENCES road_segments(segment_id)
        ON DELETE CASCADE,

    CONSTRAINT uq_segment_lane
        UNIQUE (segment_id, lane_number),

    CONSTRAINT chk_lane_number
        CHECK (lane_number > 0)
);


-- ============================================================
-- 4. ACCESOS AL CAMPUS
-- ============================================================

CREATE TABLE campus_gates (
    gate_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    location_id INT NOT NULL,
    gate_name VARCHAR(100) NOT NULL,
    direction VARCHAR(20),
    status VARCHAR(20) DEFAULT 'OPEN',

    CONSTRAINT fk_gate_location
        FOREIGN KEY (location_id)
        REFERENCES locations(location_id),

    CONSTRAINT chk_gate_status
        CHECK (status IN ('OPEN', 'CLOSED', 'RESTRICTED', 'MAINTENANCE'))
);


-- ============================================================
-- 5. CLASIFICACIÓN DE VEHÍCULOS
-- ============================================================

CREATE TABLE vehicle_classes (
    vehicle_class_id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    class_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(200)
);


-- ============================================================
-- 6. DETECCIONES DE TRÁFICO
-- ============================================================

CREATE TABLE traffic_detections (
    detection_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    device_id VARCHAR(50) NOT NULL,
    lane_id INT,
    vehicle_class_id SMALLINT,

    detected_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    speed_kmh NUMERIC(6,2),
    direction VARCHAR(20),
    confidence NUMERIC(5,4),

    CONSTRAINT fk_detection_device
        FOREIGN KEY (device_id)
        REFERENCES devices(device_id),

    CONSTRAINT fk_detection_lane
        FOREIGN KEY (lane_id)
        REFERENCES lanes(lane_id),

    CONSTRAINT fk_detection_vehicle_class
        FOREIGN KEY (vehicle_class_id)
        REFERENCES vehicle_classes(vehicle_class_id),

    CONSTRAINT chk_detection_speed
        CHECK (speed_kmh IS NULL OR speed_kmh >= 0),

    CONSTRAINT chk_detection_confidence
        CHECK (
            confidence IS NULL
            OR confidence BETWEEN 0 AND 1
        )
);


-- ============================================================
-- 7. FLUJO VEHICULAR AGREGADO
-- ============================================================

CREATE TABLE traffic_flow (
    flow_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    segment_id INT NOT NULL,

    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,

    vehicle_count INT NOT NULL DEFAULT 0,

    average_speed_kmh NUMERIC(6,2),

    occupancy NUMERIC(5,2),

    congestion_level VARCHAR(20),

    CONSTRAINT fk_flow_segment
        FOREIGN KEY (segment_id)
        REFERENCES road_segments(segment_id),

    CONSTRAINT chk_flow_period
        CHECK (end_time > start_time),

    CONSTRAINT chk_vehicle_count
        CHECK (vehicle_count >= 0),

    CONSTRAINT chk_flow_speed
        CHECK (
            average_speed_kmh IS NULL
            OR average_speed_kmh >= 0
        ),

    CONSTRAINT chk_occupancy
        CHECK (
            occupancy IS NULL
            OR occupancy BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_congestion
        CHECK (
            congestion_level IS NULL
            OR congestion_level IN (
                'LOW',
                'MODERATE',
                'HIGH',
                'SEVERE'
            )
        )
);


-- ============================================================
-- 8. SEMÁFOROS
-- ============================================================

CREATE TABLE traffic_signals (
    signal_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    device_id VARCHAR(50) UNIQUE,
    intersection_id INT NOT NULL,

    controller_mode VARCHAR(20) DEFAULT 'AUTOMATIC',
    status VARCHAR(20) DEFAULT 'ACTIVE',

    CONSTRAINT fk_signal_device
        FOREIGN KEY (device_id)
        REFERENCES devices(device_id),

    CONSTRAINT fk_signal_intersection
        FOREIGN KEY (intersection_id)
        REFERENCES intersections(intersection_id),

    CONSTRAINT chk_controller_mode
        CHECK (
            controller_mode IN (
                'AUTOMATIC',
                'MANUAL',
                'ADAPTIVE',
                'FLASHING'
            )
        ),

    CONSTRAINT chk_signal_status
        CHECK (
            status IN (
                'ACTIVE',
                'INACTIVE',
                'FAILED',
                'MAINTENANCE'
            )
        )
);


-- ============================================================
-- 9. FASES DE SEMÁFORO
-- ============================================================

CREATE TABLE signal_phases (
    phase_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    signal_id INT NOT NULL,

    phase_name VARCHAR(50) NOT NULL,

    green_seconds INT NOT NULL,
    yellow_seconds INT NOT NULL,
    red_seconds INT NOT NULL,

    CONSTRAINT fk_phase_signal
        FOREIGN KEY (signal_id)
        REFERENCES traffic_signals(signal_id)
        ON DELETE CASCADE,

    CONSTRAINT chk_green_time
        CHECK (green_seconds >= 0),

    CONSTRAINT chk_yellow_time
        CHECK (yellow_seconds >= 0),

    CONSTRAINT chk_red_time
        CHECK (red_seconds >= 0)
);


-- ============================================================
-- 10. PLANES DE SEMÁFORO
-- ============================================================

CREATE TABLE signal_plans (
    plan_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    signal_id INT NOT NULL,

    plan_name VARCHAR(100) NOT NULL,

    valid_from TIME,
    valid_to TIME,

    day_type VARCHAR(20),

    active BOOLEAN DEFAULT TRUE,

    CONSTRAINT fk_plan_signal
        FOREIGN KEY (signal_id)
        REFERENCES traffic_signals(signal_id)
        ON DELETE CASCADE
);

CREATE TABLE signal_plan_phases (
    plan_id INT NOT NULL,
    phase_id INT NOT NULL,

    sequence_number SMALLINT NOT NULL,

    PRIMARY KEY (plan_id, phase_id),

    CONSTRAINT fk_plan_phase_plan
        FOREIGN KEY (plan_id)
        REFERENCES signal_plans(plan_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_plan_phase_phase
        FOREIGN KEY (phase_id)
        REFERENCES signal_phases(phase_id)
        ON DELETE CASCADE
);


-- ============================================================
-- 11. EVENTOS DE SEMÁFOROS
-- ============================================================

CREATE TABLE signal_events (
    signal_event_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    signal_id INT NOT NULL,
    phase_id INT,

    event_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    event_type VARCHAR(30) NOT NULL,

    CONSTRAINT fk_signal_event_signal
        FOREIGN KEY (signal_id)
        REFERENCES traffic_signals(signal_id),

    CONSTRAINT fk_signal_event_phase
        FOREIGN KEY (phase_id)
        REFERENCES signal_phases(phase_id)
);


-- ============================================================
-- 12. INCIDENTES DE TRÁFICO
-- ============================================================

CREATE TABLE traffic_incidents (
    incident_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    segment_id INT,
    intersection_id INT,

    reported_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    incident_type VARCHAR(50) NOT NULL,

    severity VARCHAR(20),

    description TEXT,

    resolved_at TIMESTAMPTZ,

    status VARCHAR(20) DEFAULT 'OPEN',

    CONSTRAINT fk_incident_segment
        FOREIGN KEY (segment_id)
        REFERENCES road_segments(segment_id),

    CONSTRAINT fk_incident_intersection
        FOREIGN KEY (intersection_id)
        REFERENCES intersections(intersection_id),

    CONSTRAINT chk_incident_severity
        CHECK (
            severity IS NULL
            OR severity IN (
                'LOW',
                'MEDIUM',
                'HIGH',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_incident_status
        CHECK (
            status IN (
                'OPEN',
                'IN_PROGRESS',
                'RESOLVED'
            )
        ),

    CONSTRAINT chk_incident_location
        CHECK (
            segment_id IS NOT NULL
            OR intersection_id IS NOT NULL
        )
);


-- ============================================================
-- 13. MODELOS DE MACHINE LEARNING
-- ============================================================

CREATE TABLE ml_models (
    model_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    model_name VARCHAR(100) NOT NULL,
    version VARCHAR(30) NOT NULL,

    model_type VARCHAR(50),

    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    training_start TIMESTAMPTZ,
    training_end TIMESTAMPTZ,

    metric_name VARCHAR(50),
    metric_value NUMERIC(12,6),

    status VARCHAR(20) DEFAULT 'DEVELOPMENT',

    UNIQUE (model_name, version),

    CONSTRAINT chk_ml_status
        CHECK (
            status IN (
                'DEVELOPMENT',
                'VALIDATED',
                'DEPLOYED',
                'RETIRED'
            )
        )
);


-- ============================================================
-- 14. PREDICCIONES DE TRÁFICO
-- ============================================================

CREATE TABLE traffic_predictions (
    prediction_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    segment_id INT NOT NULL,
    model_id INT NOT NULL,

    generated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    prediction_time TIMESTAMPTZ NOT NULL,

    predicted_vehicle_count INT,

    predicted_speed_kmh NUMERIC(6,2),

    predicted_congestion VARCHAR(20),

    confidence NUMERIC(5,4),

    CONSTRAINT fk_prediction_segment
        FOREIGN KEY (segment_id)
        REFERENCES road_segments(segment_id),

    CONSTRAINT fk_prediction_model
        FOREIGN KEY (model_id)
        REFERENCES ml_models(model_id),

    CONSTRAINT chk_prediction_count
        CHECK (
            predicted_vehicle_count IS NULL
            OR predicted_vehicle_count >= 0
        ),

    CONSTRAINT chk_prediction_speed
        CHECK (
            predicted_speed_kmh IS NULL
            OR predicted_speed_kmh >= 0
        ),

    CONSTRAINT chk_prediction_confidence
        CHECK (
            confidence IS NULL
            OR confidence BETWEEN 0 AND 1
        )
);


-- ============================================================
-- 15. RECOMENDACIONES DEL SISTEMA
-- ============================================================

CREATE TABLE control_recommendations (
    recommendation_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    intersection_id INT NOT NULL,
    model_id INT,

    generated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    recommendation_type VARCHAR(50) NOT NULL,

    recommended_value VARCHAR(100),

    reason TEXT,

    confidence NUMERIC(5,4),

    status VARCHAR(20) DEFAULT 'PENDING',

    CONSTRAINT fk_recommendation_intersection
        FOREIGN KEY (intersection_id)
        REFERENCES intersections(intersection_id),

    CONSTRAINT fk_recommendation_model
        FOREIGN KEY (model_id)
        REFERENCES ml_models(model_id),

    CONSTRAINT chk_recommendation_confidence
        CHECK (
            confidence IS NULL
            OR confidence BETWEEN 0 AND 1
        ),

    CONSTRAINT chk_recommendation_status
        CHECK (
            status IN (
                'PENDING',
                'APPROVED',
                'REJECTED',
                'EXECUTED'
            )
        )
);


-- ============================================================
-- 16. ACCIONES DE CONTROL
-- ============================================================

CREATE TABLE control_actions (
    action_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    intersection_id INT NOT NULL,
    signal_id INT,

    recommendation_id BIGINT,

    model_id INT,

    action_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    action_type VARCHAR(50) NOT NULL,

    previous_value VARCHAR(100),
    new_value VARCHAR(100),

    reason TEXT,

    execution_status VARCHAR(20) DEFAULT 'EXECUTED',

    CONSTRAINT fk_action_intersection
        FOREIGN KEY (intersection_id)
        REFERENCES intersections(intersection_id),

    CONSTRAINT fk_action_signal
        FOREIGN KEY (signal_id)
        REFERENCES traffic_signals(signal_id),

    CONSTRAINT fk_action_recommendation
        FOREIGN KEY (recommendation_id)
        REFERENCES control_recommendations(recommendation_id),

    CONSTRAINT fk_action_model
        FOREIGN KEY (model_id)
        REFERENCES ml_models(model_id),

    CONSTRAINT chk_execution_status
        CHECK (
            execution_status IN (
                'PENDING',
                'EXECUTED',
                'FAILED',
                'CANCELLED'
            )
        )
);


-- ============================================================
-- 17. EVENTOS DEL CAMPUS
-- ============================================================

CREATE TABLE campus_events (
    event_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    event_name VARCHAR(150) NOT NULL,

    location_id INT,

    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,

    expected_attendance INT,

    event_type VARCHAR(50),

    description TEXT,

    CONSTRAINT fk_event_location
        FOREIGN KEY (location_id)
        REFERENCES locations(location_id),

    CONSTRAINT chk_event_period
        CHECK (end_time > start_time),

    CONSTRAINT chk_event_attendance
        CHECK (
            expected_attendance IS NULL
            OR expected_attendance >= 0
        )
);


-- ============================================================
-- 18. ÍNDICES
-- ============================================================

CREATE INDEX idx_sensor_readings_device_time
    ON sensor_readings(device_id, recorded_at DESC);

CREATE INDEX idx_traffic_detection_time
    ON traffic_detections(detected_at DESC);

CREATE INDEX idx_traffic_detection_lane_time
    ON traffic_detections(lane_id, detected_at DESC);

CREATE INDEX idx_traffic_flow_segment_time
    ON traffic_flow(segment_id, start_time DESC);

CREATE INDEX idx_predictions_segment_time
    ON traffic_predictions(segment_id, prediction_time DESC);

CREATE INDEX idx_incidents_status
    ON traffic_incidents(status);

CREATE INDEX idx_control_actions_time
    ON control_actions(action_time DESC);

CREATE INDEX idx_signal_events_time
    ON signal_events(signal_id, event_time DESC);